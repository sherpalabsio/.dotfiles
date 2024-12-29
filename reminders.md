# Reminders

## Xcode

```bash
xcode-select --install
```

## Fix "App is damaged and can't be opened" issue
```bash
xattr -d com.apple.quarantine `which chromedriver`
```
