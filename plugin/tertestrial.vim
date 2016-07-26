function! TestFile()
  let command = '{"operation": "testFile", "filename": "'.bufname('%').'"}'
  let message = 'testing file '.bufname('%')
  call SendTestCommand(command, message)
endfunction


function! TestLine()
  let command = '{"operation": "testLine", "filename": "'.bufname('%').'", "line": "'.line('.').'"}'
  let message = 'testing file '.bufname('%').' at line '.line('.')
  call SendTestCommand(command, message)
endfunction


function! RepeatLastTest()
  let command = '{"operation": "repeat_last_test"}'
  let message = 'repeating last test'
  call SendTestCommand(command, message)
endfunction


function! SendTestCommand(data, message)
  if findfile('tertestrial.tmp', '.;') == 'tertestrial.tmp'
    call writefile([a:data], 'tertestrial.tmp')
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
