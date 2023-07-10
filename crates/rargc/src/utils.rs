use convert_case::{Boundary, Converter, Pattern};

/// Convert a string to cobol case
pub fn to_cobol_case(value: &str) -> String {
    Converter::new()
        .set_pattern(Pattern::Uppercase)
        .set_delim("-")
        .set_boundaries(&[Boundary::Underscore, Boundary::LowerUpper, Boundary::Hyphen])
        .convert(value)
}

/// Convert a string from snake_case to camelCase
pub fn hyphens_to_underscores(name: &str) -> String {
    name.replace('-', "_")
}

/// Escape a string for use in a shell command
pub fn escape_shell_words(value: &str) -> String {
    let mut output = String::new();
    if value.is_empty() {
        return "''".to_string();
    }
    for ch in value.chars() {
        match ch {
            'A'..='Z' | 'a'..='z' | '0'..='9' | '_' | '-' | '.' | ',' | ':' | '/' | '@' => {
                output.push(ch)
            }
            '\n' => output.push_str("'\n'"),
            _ => {
                output.push('\\');
                output.push(ch);
            }
        }
    }
    output
}

/// Is the character a valid choice value terminator
pub fn is_choice_value_terminate(c: char) -> bool {
    c == '|' || c == ']'
}

/// Is the character a valid default value terminator
pub fn is_default_value_terminate(c: char) -> bool {
    c.is_whitespace()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cobol() {
        assert_eq!("FOO-BAR".to_string(), to_cobol_case("fooBar"));
        assert_eq!("FOO-BAR".to_string(), to_cobol_case("foo-bar"));
        assert_eq!("FOO1".to_string(), to_cobol_case("foo1"));
    }
}
