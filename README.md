# thermal_test

30 s all-core load, then report per-core peak temperatures and the spread (a quick check of thermal paste).

## Requirements

stress-ng, lm-sensors (expects an Intel `Package id 0` line).

## Use

```
chmod +x thermal-test.sh
./thermal-test.sh
```

Made for Debian. Run it from its folder or put it on your `PATH`. Run it with `-h` where supported, or read the comment header at the top of the script.

## License

MIT - see [LICENSE](LICENSE).
