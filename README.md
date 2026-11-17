# passgen

**passgen** generates a pseudorandom passphrase from a configurable wordlist.

## Randomness

**passgen** uses `sort(1)`'s -R flag to pick the words.

Random number generation is done via `jot(1)` when available. Otherwise, the `rand()` function from `awk(1)` is used. `awk(1)` is seeded with four bytes read from `/dev/urandom` followed by **passgen**'s process id.

## Setup

Download your desired wordlist. I recommend [EFF's large wordlist](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt).

Install the wordlist at `/usr/local/share/dict/wordlist` or your preferred path.

The wordlist must have the same format as EFF's large wordlist.

Install the script and its manual:

```sh
install -o 0 -g 0 -m 555 passgen.sh /usr/local/bin/passgen
gzip -c passgen.1 >> passgen.1.gz
install -o 0 -g 0 -m 644 passgen.1.gz /usr/local/share/man/man1
```

**Note:** The install commands require root privileges.

## Usage

```sh
passgen [-p path] [-w count] [-c max] [-n max]
```

## Options

- `-p path`

Provide the wordlist to be used, defaults to `/usr/local/share/dict/wordlist`.

- `-w count`

Set the word count for the passphrase with a minimum of 3, defaults to 5.

- `-c max`

Set the upper bound for how many words may be capitalized, defaults to half the words.

- `-n max`

Set the upper bound for how many words may be appended by a number, defaults to the value specified by -c.

## License

[BSD-3-Clause](LICENSE)
