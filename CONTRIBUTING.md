# Tertestrial Server Developer Documentation


## Wire format

The commands sent by the Tertestrial clients contain the following fields:
* __filename:__ the current file name
* __line:__ the current line number in the current file
* __filetype:__ what the editor assumes is the type of the file
  * `cucumber`
  * `javascript`
* __operation:__ what to do
  * `test_file`: test the given file
  * `test_file_line`: test the given file at the given line
  * `repeat_last_test`: repeat the last test sent

The wire format is valid Bash code. An example looks like this:

```bash
operation="test_file_line"; filetype="cucumber"; filename="features/foo.feature"; line="23"
```
