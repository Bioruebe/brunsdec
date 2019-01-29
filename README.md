# brunsdec
A simple decryptor for Bruns Engine encrypted files (with magic number `EENC`)

### Usage
`brunsdec <input_file>|<input_dir> [<output_dir>]`

- brunsdec supports either a single file or a whole folder as input. In folder mode only files with magic number `EENC` are processed. Subdirectories are ++ignored++.

### Technical details
Bruns Engine games make use of two different file formats:

-  `EENZ`: Files starting with the magic number `45 45 4E 5A` are generally used for text content (configuration, level data) and fonts. This kind of encryption is not supported by brunsdec.
- `EENC`: Encrpyted PNG images start with the magic number `45 45 4E 43` and can be decrypted by brunsdec. The next 4 bytes can be used to derive the encryption key, which is different for each file. To do so, XOR the value with `0xDEADBEEF` to get the decryption key. (Attention: the byte order is important! See code for details.) Then simply XOR the rest of the file with the decryption key and save as PNG.

### Limitations
- Files with the magic number `EENZ` are not supported
- If you found a game, which is not supported, feel free to open an issue and send me a sample file.

### Remarks
This is the result of analysing the file type itself, no reverse engineering has been used to write this tool.

I released it as a helper for artists to search games for unlicensed use of their assets. It is not meant to encourage extraction with the sole purpose of using assets in your own products without permission of the copyright holder.

Remember: don't steal assets from other people's games. Respect copyrights. And don't protect your own games - it's unnecessary effort.
