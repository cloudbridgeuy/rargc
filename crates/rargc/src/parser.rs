use color_eyre::eyre::{self, Result};

use crate::param;

pub type Position = usize;

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Token {
    pub data: Data,
    pub position: Position,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum Data {
    Author(Vec<String>),
    Cmd(String),
    Description(String),
    Flag(param::Flag),
    Func(String),
    Help(String),
    Name(String),
    Option(param::Option),
    Version(String),
    Default(String),
    Unknown(String),
}

/// Parse a source string into a list of tokens.
pub fn parse_source(source: &str) -> Result<Vec<Token>> {
    let mut tokens = vec![];

    for (index, line) in source.lines().enumerate() {
        let position = index + 1;

        match parse_line(line) {
            Ok(Some(token)) => tokens.push(Token {
                data: token,
                position,
            }),
            Ok(None) => {
                println!("Add a debug! trace here");
            }
            Err(e) => return Err(e),
        }
    }

    Ok(tokens)
}

/// Parse a line into a token.
pub fn parse_line(line: &str) -> Result<Option<Data>> {
    let maybe = nom::branch::alt((
        nom::combinator::map(nom::branch::alt((parse_tag, parse_fn)), Some),
        nom::combinator::success(None),
    ))(line);

    match maybe {
        Ok((_rest_of_line, maybe_token)) => {
            if let Some(maybe_data) = maybe_token {
                if let Some(data) = maybe_data {
                    Ok(Some(data))
                } else {
                    // Add a tracing debug! message here to substitue
                    // Err(eyre::format_err!("syntax error on line \"{}\"", line))
                    Ok(Some(Data::Unknown(line.to_string())))
                }
            } else {
                Ok(None)
            }
        }
        Err(e) => Err(eyre::format_err!(
            "fail to parse line \"{}\" with error: {}",
            line,
            e
        )),
    }
}

/// Parses an input as if it was a bash comment with a tag such as
/// `# @name rest...`, `# @description rest...`, etc.
fn parse_tag(input: &str) -> nom::IResult<&str, Option<Data>> {
    nom::sequence::preceded(
        nom::sequence::tuple((
            nom::multi::many1(nom::character::complete::char('#')),
            nom::character::complete::space0,
            nom::character::complete::char('@'),
        )),
        nom::branch::alt((parse_tag_text, parse_tag_param, parse_tag_unknown)),
    )(input)
}

/// Parses the input as if it was a text tag, such as `@name`, `@description`, etc.
fn parse_tag_text(input: &str) -> nom::IResult<&str, Option<Data>> {
    nom::combinator::map(
        nom::sequence::pair(
            nom::branch::alt((
                nom::bytes::complete::tag("author"),
                nom::bytes::complete::tag("cmd"),
                nom::bytes::complete::tag("description"),
                nom::bytes::complete::tag("default"),
                nom::bytes::complete::tag("help"),
                nom::bytes::complete::tag("name"),
                nom::bytes::complete::tag("version"),
            )),
            parse_tail,
        ),
        |(tag, text)| {
            let text = text.to_string();

            Some(match tag {
                "author" => Data::Author(text.split(',').map(|v| v.trim().to_string()).collect()),
                "cmd" => Data::Cmd(text),
                "description" => Data::Description(text),
                "default" => Data::Default(text),
                "help" => Data::Help(text),
                "name" => Data::Name(text),
                "version" => Data::Version(text),
                _ => unreachable!(),
            })
        },
    )(input)
}

/// Parses the input as if it was the tail of a line, getting everything after the first space,
/// and checking that we haven't reached the EOF.
fn parse_tail(input: &str) -> nom::IResult<&str, &str> {
    nom::branch::alt((
        nom::combinator::eof,
        nom::sequence::preceded(
            nom::character::complete::space0,
            nom::branch::alt((
                nom::combinator::eof,
                nom::combinator::map(nom::combinator::rest, |v: &str| v.trim()),
            )),
        ),
    ))(input)
}

/// Parses the input as if it was an unknown tag.
fn parse_tag_unknown(input: &str) -> nom::IResult<&str, Option<Data>> {
    nom::combinator::map(parse_word, |v| Some(Data::Unknown(v.to_string())))(input)
}

/// Parses the input as if it was a word consisting of alphanumeric characters, underscores, or dashes.
fn parse_word(input: &str) -> nom::IResult<&str, &str> {
    nom::bytes::complete::take_while1(is_name_char)(input)
}

/// Parses the input as if it was a function.
fn parse_fn(input: &str) -> nom::IResult<&str, Option<Data>> {
    nom::combinator::map(
        nom::branch::alt((parse_fn_keyword, parse_fn_no_keyword)),
        |v| Some(Data::Func(v.to_string())),
    )(input)
}

/// Parses the intput as if it was a function with the `function` keyword.
fn parse_fn_keyword(input: &str) -> nom::IResult<&str, &str> {
    nom::sequence::preceded(
        nom::sequence::tuple((
            nom::character::complete::space0,
            nom::bytes::complete::tag("function"),
            nom::character::complete::space1,
        )),
        parse_fn_name,
    )(input)
}

/// Parses the input as if it was a function name.
fn parse_fn_name(input: &str) -> nom::IResult<&str, &str> {
    nom::bytes::complete::take_while1(is_not_fn_name_char)(input)
}

/// Parses the input as if it was a function without the `function` keyword.
fn parse_fn_no_keyword(input: &str) -> nom::IResult<&str, &str> {
    nom::sequence::preceded(
        nom::character::complete::space0,
        nom::sequence::terminated(
            parse_fn_name,
            nom::sequence::tuple((
                nom::character::complete::space0,
                nom::character::complete::char('('),
                nom::character::complete::space0,
                nom::character::complete::char(')'),
            )),
        ),
    )(input)
}

/// Parse the input as if it was a tag parameter like `@option rest...`, `@flag rest...`, or `@arg rest...`.
fn parse_tag_param(input: &str) -> nom::IResult<&str, Option<Data>> {
    let check = nom::combinator::peek(nom::branch::alt((
        nom::bytes::complete::tag("flag"),
        nom::bytes::complete::tag("option"),
        // nom::bytes::complete::tag("arg"),
    )));

    let arg = nom::branch::alt((
        nom::combinator::map(
            nom::sequence::preceded(
                nom::sequence::pair(
                    nom::bytes::complete::tag("flag"),
                    nom::character::complete::space1,
                ),
                parse_flag_param,
            ),
            |param| Some(Data::Flag(param)),
        ),
        nom::combinator::map(
            nom::sequence::preceded(
                nom::sequence::pair(
                    nom::bytes::complete::tag("option"),
                    nom::character::complete::space1,
                ),
                parse_option_param,
            ),
            |param| Some(Data::Option(param)),
        ),
        // nom::combinator::map(
        //     nom::sequence::preceded(
        //         nom::sequence::pair(
        //             nom::bytes::complete::tag("arg"),
        //             nom::character::complete::space1,
        //         ),
        //         parse_arg_param,
        //     ),
        //     |param| Some(Data::Arg(param)),
        // ),
    ));

    nom::sequence::preceded(
        check,
        nom::branch::alt((arg, nom::combinator::success(None))),
    )(input)
}

/// Parses the input as if it was a flag parameter like `@flag -h --help <summary>`.
fn parse_flag_param(input: &str) -> nom::IResult<&str, param::Flag> {
    nom::combinator::map(
        nom::sequence::tuple((
            parse_short,
            nom::sequence::preceded(
                nom::sequence::pair(
                    nom::character::complete::space0,
                    nom::bytes::complete::tag("--"),
                ),
                parse_param_name,
            ),
            parse_tail,
        )),
        |(short, data, summary)| param::Flag::new(data, summary, short),
    )(input)
}

/// Parses the input as if it was an on option parameter like `@option --help <summary>`.
fn parse_option_param(input: &str) -> nom::IResult<&str, param::Option> {
    nom::combinator::map(
        nom::sequence::tuple((
            parse_short,
            nom::sequence::preceded(
                nom::sequence::pair(
                    nom::character::complete::space0,
                    nom::bytes::complete::tag("--"),
                ),
                nom::branch::alt((
                    parse_param_choices_default,
                    parse_param_choices_required,
                    parse_param_choices,
                    parse_param_assign,
                    parse_param_mark,
                )),
            ),
            parse_value_notation,
            parse_tail,
        )),
        |(short, data, value_notation, summary)| {
            param::Option::new(data, summary, short, value_notation.map(|v| v.to_string()))
        },
    )(input)
}

fn parse_value_notation(input: &str) -> nom::IResult<&str, Option<&str>> {
    let main = nom::sequence::delimited(
        nom::character::complete::char('<'),
        nom::bytes::complete::take_while1(|c: char| c.is_ascii_uppercase() || c == '_'),
        nom::character::complete::char('>'),
    );

    nom::combinator::opt(nom::sequence::preceded(
        nom::character::complete::space0,
        main,
    ))(input)
}

/// Parses the input as if was marked as `required` or `multiple`. E.g. `@param!`, `@param*`, `@param+`.
fn parse_param_mark(input: &str) -> nom::IResult<&str, param::Data> {
    nom::branch::alt((
        nom::combinator::map(
            nom::sequence::terminated(parse_param_name, nom::bytes::complete::tag("!")),
            |mut data| {
                data.required = true;
                data
            },
        ),
        nom::combinator::map(
            nom::sequence::terminated(parse_param_name, nom::bytes::complete::tag("*")),
            |mut data| {
                data.multiple = true;
                data
            },
        ),
        nom::combinator::map(
            nom::sequence::terminated(parse_param_name, nom::bytes::complete::tag("+")),
            |mut data| {
                data.required = true;
                data.multiple = true;
                data
            },
        ),
        parse_param_name,
    ))(input)
}

/// Parses the input as if it was a value notation like `str=value`.
fn parse_param_assign(input: &str) -> nom::IResult<&str, param::Data> {
    nom::combinator::map(
        nom::sequence::separated_pair(
            parse_param_name,
            nom::character::complete::char('='),
            parse_default_value,
        ),
        |(mut data, value)| {
            data.default = Some(value.to_string());
            data
        },
    )(input)
}

/// Parses the input as if it was a value notation like `str[a|b|c]`.
fn parse_param_choices(input: &str) -> nom::IResult<&str, param::Data> {
    nom::combinator::map(
        nom::sequence::pair(
            parse_param_name,
            nom::sequence::delimited(
                nom::character::complete::char('['),
                parse_choices,
                nom::character::complete::char(']'),
            ),
        ),
        |(mut data, (choices, default))| {
            data.choices = Some(choices.iter().map(|v| v.to_string()).collect());
            data.default = default.map(|v| v.to_string());
            data
        },
    )(input)
}

/// Parses the input as if it was a value notation with a default value like `str![=a|b|c]`.
fn parse_param_choices_required(input: &str) -> nom::IResult<&str, param::Data> {
    nom::combinator::map(
        nom::sequence::pair(
            nom::sequence::terminated(parse_param_name, nom::character::complete::char('!')),
            nom::sequence::delimited(
                nom::character::complete::char('['),
                parse_choices,
                nom::character::complete::char(']'),
            ),
        ),
        |(mut data, (choices, default))| {
            data.choices = Some(choices.iter().map(|v| v.to_string()).collect());
            data.required = true;
            data.default = default.map(|v| v.to_string());
            data
        },
    )(input)
}

/// Parses the input as if it was a value notation with a default value like `str[=a|b|c]`.
fn parse_param_choices_default(input: &str) -> nom::IResult<&str, param::Data> {
    nom::combinator::map(
        nom::sequence::pair(
            parse_param_name,
            nom::sequence::delimited(
                nom::character::complete::char('['),
                parse_choices_default,
                nom::character::complete::char(']'),
            ),
        ),
        |(mut data, (choices, default))| {
            data.choices = Some(choices.iter().map(|v| v.to_string()).collect());
            data.default = default.map(|v| v.to_string());
            data
        },
    )(input)
}

/// Parses the input as if it was a list of possible values like `=a|b|c`.
fn parse_choices_default(input: &str) -> nom::IResult<&str, (Vec<&str>, Option<&str>)> {
    nom::combinator::map(
        nom::sequence::tuple((
            nom::character::complete::char('='),
            parse_choice_value,
            nom::multi::many1(nom::sequence::preceded(
                nom::character::complete::char('|'),
                parse_choice_value,
            )),
        )),
        |(_, head, tail)| {
            let mut choices = vec![head];
            choices.extend(tail);
            (choices, Some(head))
        },
    )(input)
}

/// Parses the input as if it had a default value like `str=value` or `str="value"`.
fn parse_default_value(input: &str) -> nom::IResult<&str, &str> {
    nom::branch::alt((
        parse_quoted_string,
        nom::bytes::complete::take_till(is_default_value_terminate),
    ))(input)
}

/// Parses the input as if it was a list of possible values like `a|b|c`.
fn parse_choices(input: &str) -> nom::IResult<&str, (Vec<&str>, Option<&str>)> {
    nom::combinator::map(
        nom::multi::separated_list1(nom::character::complete::char('|'), parse_choice_value),
        |choices| (choices, None),
    )(input)
}

/// Parses the input as if it was a value like `str` or `"str"`.
fn parse_choice_value(input: &str) -> nom::IResult<&str, &str> {
    if input.starts_with('=') {
        return nom::combinator::fail(input);
    }
    nom::branch::alt((
        parse_quoted_string,
        nom::bytes::complete::take_till(is_choice_value_terminate),
    ))(input)
}

fn parse_quoted_string(input: &str) -> nom::IResult<&str, &str> {
    let single = nom::sequence::delimited(
        nom::character::complete::char('\''),
        nom::branch::alt((
            nom::bytes::complete::escaped(
                nom::character::streaming::none_of("\\\'"),
                '\\',
                nom::character::complete::char('\''),
            ),
            nom::bytes::complete::tag(""),
        )),
        nom::character::complete::char('\''),
    );

    let double = nom::sequence::delimited(
        nom::character::complete::char('"'),
        nom::branch::alt((
            nom::bytes::complete::escaped(
                nom::character::streaming::none_of("\\\""),
                '\\',
                nom::character::complete::char('"'),
            ),
            nom::bytes::complete::tag(""),
        )),
        nom::character::complete::char('"'),
    );

    nom::branch::alt((single, double))(input)
}

/// Returns true if the character is a `|` or `]` which terminates a choice value.
pub fn is_choice_value_terminate(c: char) -> bool {
    c == '|' || c == ']'
}

/// Returns true if the character is a whitespace which terminates a default value.
pub fn is_default_value_terminate(c: char) -> bool {
    c.is_whitespace()
}

/// Parses the input as if it was a short option like `-h`.
fn parse_short(input: &str) -> nom::IResult<&str, Option<char>> {
    let short = nom::sequence::delimited(
        nom::character::complete::char('-'),
        nom::character::complete::satisfy(|c| c.is_ascii_alphanumeric()),
        nom::combinator::peek(nom::character::complete::space1),
    );

    nom::combinator::opt(short)(input)
}

/// Parses the input as if it was a parameter name like `--help`.
fn parse_param_name(input: &str) -> nom::IResult<&str, param::Data> {
    nom::combinator::map(parse_name, param::Data::new)(input)
}

/// Parses the input as if it was a string of ascii alphanumeric text, plus `-` or `_`.
fn parse_name(input: &str) -> nom::IResult<&str, &str> {
    nom::bytes::complete::take_while1(is_name_char)(input)
}

/// Returns true if the character is not a valid bash function name character.
fn is_not_fn_name_char(c: char) -> bool {
    !matches!(
        c,
        ' ' | '\t'
            | '"'
            | '\''
            | '`'
            | '('
            | ')'
            | '['
            | ']'
            | '{'
            | '}'
            | '<'
            | '>'
            | '$'
            | '&'
            | '\\'
            | ';'
            | '|'
    )
}

/// Returns true if the character is an ascii alphanumeric character, underscore, or dash.
fn is_name_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '_' || c == '-'
}
