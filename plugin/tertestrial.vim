function! TestFile()
  call SendTestCommand( 'operation="test_file"; filetype="'.&filetype.'"; filename="'.bufname('%').'"',
                        'testing file '.bufname('%') )
endfunction


function! TestFileLine()
  call SendTestCommand( 'operation="test_file_line"; filetype="'.&filetype.'"; filename="'.bufname('%').'"; line="'.line('.').'"',
                        'testing file '.bufname('%').' at line '.line('.') )
endfunction


function! RepeatLastTest()
  call SendTestCommand( 'operation="repeat_last_test"',
                        'repeating last test' )
endfunction


function! SendTestCommand(data, message)
  if findfile('tertestrial', '.') == 'tertestrial'
    call writefile([a:data], 'tertestrial')
  else
    echo "ERROR: Tertestrial server is not running!"
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
