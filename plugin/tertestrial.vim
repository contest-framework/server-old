function! TestFile()
  call SendTestCommand( 'operation="test_file"; filetype="'.&filetype.'"; filename="'.bufname('%').'"' )
  echo 'testing file'
endfunction

function! TestFileLine()
  call SendTestCommand( 'operation="test_file_line"; filetype="'.&filetype.'"; filename="'.bufname('%').'"; line="'.line('.').'"' )
  echo 'testing file at line'
endfunction

function! RepeatLastTest()
  call SendTestCommand( 'operation="repeat_last_test"' )
  echo 'repeating last test'
endfunction

function! SendTestCommand(data)
  call writefile([a:data], 'tertestrial')
endfunction

let g:autotest = 0
function! ToggleTestAutorun()
  let g:autotest = 1 - g:autotest
  if g:autotest
    echo 'Tertestrial AutoTest ON'
  else
    echo 'Tertestrial AutoTest OFF'
  endif
endfunction
