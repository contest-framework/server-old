function! TestFile()
  let command = 'operation="test_file"; filetype="'.&filetype.'"; filename="'.bufname('%').'"'
  let message = 'testing file '.bufname('%')
  call SendTestCommand(command, message)
endfunction


function! TestFileLine()
  let command = 'operation="test_file_line"; filetype="'.&filetype.'"; filename="'.bufname('%').'"; line="'.line('.').'"'
  let message = 'testing file '.bufname('%').' at line '.line('.')
  call SendTestCommand(command, message)
endfunction


function! RepeatLastTest()
  let command = 'operation="repeat_last_test"'
  let message = 'repeating last test'
  call SendTestCommand(command, message)
endfunction


function! SendTestCommand(data, message)
  if findfile('tertestrial', '.') == 'tertestrial'
    call writefile([a:data], 'tertestrial')
  else
    echoerr "ERROR: Tertestrial server is not running!"
  endif
endfunction


let g:autotest = 0
function! ToggleTestAutorun()
  let g:autotest = 1 - g:autotest
  if g:autotest
    echo 'AutoTest ON'
  else
    echo 'AutoTest OFF'
  endif
endfunction
