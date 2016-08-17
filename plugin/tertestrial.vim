function! g:TertestrialAll()
  let command = '{}'
  let message = 'running all tests'
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialFile()
  let command = '{"filename": "'.bufname('%').'"}'
  let message = 'testing file '.bufname('%')
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialLine()
  let command = '{"filename": "'.bufname('%').'", "line": "'.line('.').'"}'
  let message = 'testing file '.bufname('%').' at line '.line('.')
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialRepeat(...)
  let command = '{"repeatLastTest": true}'
  if a:0 == 1
    let message = ''
  else
    let message = 'repeating last test'
  endif
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialSet(actionSet)
  let command = '{"actionSet": '.a:actionSet.'}'
  let message = 'Activate action set '.a:actionSet
  call SendTestCommand(command, message)
endfunction


function! g:TertestrialFileSaved()
  if g:tertestrialAutotest
    call TertestrialRepeat('autorepeating')
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
    if a:message != ''
      echo a:message
    endif
  else
    echoerr "ERROR: Tertestrial server is not running!"
  endif
endfunction
