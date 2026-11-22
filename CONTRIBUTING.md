# Contributing to Spendly

Thank you for your interest in contributing to Spendly! 🎉

## Code of Conduct

Please be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Bugs
1. Check if the issue already exists in [Issues](https://github.com/seira-14/spendly/issues)
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Device/OS information
   - Screenshots if applicable

### Suggesting Features
1. Open an issue with the `enhancement` label
2. Describe the feature and why it would be useful
3. Include mockups or examples if possible

### Submitting Code

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/spendly.git
   ```
3. **Create a branch** with a descriptive name:
   ```bash
   git checkout -b feature/budget-planning
   # or
   git checkout -b fix/login-token-issue
   ```
4. **Make your changes** following the code style guidelines below
5. **Run analysis**:
   ```bash
   cd frontend && flutter analyze
   ```
6. **Commit** with a clear message:
   ```bash
   git commit -m "feat: add monthly budget planning feature"
   ```
7. **Push** to your fork:
   ```bash
   git push origin feature/budget-planning
   ```
8. **Open a Pull Request** against the `main` branch

## Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Usage |
|--------|-------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation only |
| `style:` | Formatting, no logic change |
| `refactor:` | Code refactor |
| `test:` | Adding tests |
| `chore:` | Build/tooling changes |

## Code Style

### Flutter / Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before submitting — zero errors/warnings required
- Use meaningful variable and function names
- Add comments for complex logic

### Laravel / PHP
- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standards
- Use type hints in function signatures
- Write clear PHPDoc comments for public methods

## Security

**Never commit:**
- `.env` files
- API keys, tokens, or secrets
- Passwords or personal data
- `google-services.json` or `GoogleService-Info.plist`

## Author

**Alifah Ghina S** — [github.com/seira-14](https://github.com/seira-14)
