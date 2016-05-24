function! TestFile()
  call SendTestCommand( 'operation="test_file"; filetype="'.&filetype.'"; filename="'.bufname('%').'"' )
  echo 'testing file '.bufname('%')
endfunction

function! TestFileLine()
  call SendTestCommand( 'operation="test_file_line"; filetype="'.&filetype.'"; filename="'.bufname('%').'"; line="'.line('.').'"' )
  echo 'testing file '.bufname('%').' at line '.line('.')
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
    echo 'AutoTest ON'
  else
    echo 'AutoTest OFF'
  endif
endfunction
