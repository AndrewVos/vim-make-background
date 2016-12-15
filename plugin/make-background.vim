if exists("g:loaded_make_background")
  finish
endif
let g:loaded_make_background = 1

function! BackgroundCommandExit(job, exitStatus)
  execute "cfile! " . g:backgroundCommandOutput
  copen
  unlet g:backgroundCommandOutput

  if exitStatus > 0
    echohl Error
    echo 'FAIL'
    echohl None
  else
    echo 'PASS'
  endif
endfunction

function! MakeBackground(args)
  if v:version < 800
    echoerr 'MakeBackground requires VIM version 8 or higher'
    return
  endif

  if exists('g:backgroundCommandOutput')
    echo 'Already running task in background'
  else
    echo 'Running task in background'
    let g:backgroundCommandOutput = tempname()

    if empty(&l:makeprg)
      let makeprg = &g:makeprg
    else
      let makeprg = &l:makeprg
    endif

    let command = makeprg
    if !empty(a:args)
      let command = command . ' ' . a:args
    end

    echomsg command
    call job_start(command, {'exit_cb': function('BackgroundCommandExit'), 'err_io': 'file', 'err_name': g:backgroundCommandOutput, 'out_io': 'file', 'out_name': g:backgroundCommandOutput})
  endif
endfunction
command! -nargs=* -complete=file MakeBackground call MakeBackground(<q-args>)
