function! pbrowse#browse(line1, line2, count) abort
  if has('win32') || has('win64')
    echoerr "Windows is not supported. Please use WSL (Windows Subsystem for Linux) instead."
    return
  end

  " Get current PR URL using gh command
  let l:pr_url = trim(system('gh pr view --json url --jq .url'))
  if v:shell_error != 0
    echoerr "Failed to get PR URL. Make sure you're in a git repository with an active PR and gh CLI is installed."
    return
  endif

  " Get git root directory
  let l:git_root = trim(system('git rev-parse --show-toplevel'))
  if v:shell_error != 0
    echoerr "Failed to get git root directory. Make sure you're in a git repository."
    return
  endif

  " Get full path of current file and make it relative to git root
  let l:full_path = expand('%:p')
  let l:git_root_path = l:git_root . '/'
  let l:file_path = l:full_path
  if l:full_path[0:len(l:git_root_path)-1] ==# l:git_root_path
    let l:file_path = l:full_path[len(l:git_root_path):]
  else
    echoerr "Current file is not within the git repository"
    return
  endif

  " Create hash of the file path using sha256
  let l:file_hash = trim(system('echo -n "' . l:file_path . '" | shasum -a 256'))
  let l:file_hash = split(l:file_hash)[0]
  
  " Build the URL
  let l:url = l:pr_url . '/files#diff-' . l:file_hash
  
  " Add line information only if it's a selection or a specific line
  if a:count > 0
    if a:line1 == a:line2
      let l:url = l:url . 'R' . a:line1
    else
      let l:url = l:url . 'R' . a:line1 . '-R' . a:line2
    endif
  endif
  
  if has('mac')
    call system('open ' . shellescape(l:url))
  elseif has('unix')
    call system('xdg-open ' . shellescape(l:url))
  else
    echoerr "Unsupported platform for opening URL"
  endif
endfunction
