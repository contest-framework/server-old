function! g:TertestrialFile()
  let command = '{"operation": "testFile", "filename": "'.bufname('%').'"}'
  let message = 'testing file '.bufname('%')
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialLine()
  let command = '{"operation": "testLine", "filename": "'.bufname('%').'", "line": "'.line('.').'"}'
  let message = 'testing file '.bufname('%').' at line '.line('.')
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialRepeat(autorepeating)
  let command = '{"operation": "repeatLastTest"}'
  if a:autorepeating
    let message = 'repeating last test'
  else
    let message = ''
  endif
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialSet(mapping)
  let command = '{"operation": "setMapping", "mapping": '.a:mapping.'}'
  let message = 'Set mapping '.a:mapping
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialFileSaved()
  if g:tertestrialAutotest
    call TertestrialRepeat(1)
  endif
endfunction


let g:tertestrialAutotest = 0
function! g:TertestrialToggle()
  let g:tertestrialAutotest = 1 - g:tertestrialAutotest
  if g:tertestrialAutotest
    echo 'AutoTest ON'
  else
    echo 'AutoTest OFF'
  endif
endfunction



function! SendTestCommand(data, message)
  if findfile('.tertestrial.tmp', '.;') == '.tertestrial.tmp'
    call writefile([a:data], '.tertestrial.tmp')
    if a:message == ''
      echo 'no echo here'
    else
      echo a:message
    endif
  else
    echoerr "ERROR: Tertestrial server is not running!"
  endif
endfunction
