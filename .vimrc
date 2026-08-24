set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set ignorecase
set nocompatible
filetype plugin indent on
set nowrap
vnoremap d <Esc>$
vnoremap s <Esc>0
function! ModoBuscarOn()
    nnoremap <BS> n
    nnoremap <Space> N
endfunction
"manu
vnoremap v y/<C-r>"<CR>:call ModoBuscarOn()<CR>
vnoremap t <Esc>:call ModoBuscarOn()<CR>
set foldmethod=indent
set foldlevel=0
set foldtext=CustomFoldText()
highlight Folded guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE
function! CustomFoldText()
   return '--------------------------------------------'
endfunction

tnoremap ; <C-\><C-n>
tnoremap <BS> <C-\><C-n><C-w><C-w>
inoremap <CR> <C-P>

inoremap <Tab>d =
inoremap <Tab>a :
inoremap <Tab>s .
inoremap <Tab>f /
inoremap <Tab>w ,
inoremap <Tab>e $
inoremap <Tab>r ()<Left>
inoremap <Tab>z <><Left>
inoremap <Tab>x &
inoremap <Tab>c ""<Left>
inoremap <Tab>i +
inoremap <Tab>t *
inoremap <Tab>v -
inoremap <Tab>k _
inoremap <Tab>q #
inoremap <Tab>y %
inoremap <Tab>l ''<Left>
inoremap <Tab>g {}<Left>
inoremap <Tab>p []<Left>
inoremap <Tab>o @
inoremap <Tab>u ;
inoremap <Tab>n \
inoremap <Tab>m \|
inoremap <Tab>b !
inoremap <Tab><Tab> <Right>
nnoremap <BS> u
nnoremap <Space> <C-r>
vnoremap m <DEL><Esc>
nnoremap ; :call ResetDefault()<CR>
function! ResetNumberMap()
    iunmap l
    iunmap k
    iunmap j
    iunmap p
    iunmap o
    iunmap u
    iunmap n
    iunmap m
    iunmap b
    iunmap g
    iunmap a
    echo "salio modo numero "
endfunction
    
function! NumberMode()
    inoremap l 1
    inoremap k 2
    inoremap j 3
    inoremap p 4
    inoremap o 5
    inoremap u 6
    inoremap n 7
    inoremap m 8
    inoremap b 9
    inoremap g 0
    inoremap a <Esc>:call ResetNumberMap()<CR>a
    echo "modo numero "
endfunction
inoremap <Tab><BS> <Esc>:call NumberMode()<CR>a

function! ResetDefault()
    nnoremap <BS> u
    nnoremap <Space> <C-r>
    echo "<BS>->undo, <Space>->redo"
endfunction

inoremap ; <Esc>:call ResetDefault()<CR>
vnoremap ; <Esc>:call ResetDefault()<CR>
nnoremap i v
      
vnoremap n <Esc>:q!<CR>
nnoremap s :w!<CR>
nnoremap x dd
nnoremap p <Up>
nnoremap o <Down>
nnoremap q zo
nnoremap z zc 
vnoremap z <Esc>zM 
vnoremap q <Esc>zR 
vnoremap l <gv 
vnoremap p >gv 

nnoremap u "+yy
nnoremap w "+p
vnoremap u "+y<Esc>
vnoremap w "+p<Esc>
function! SmartSplitBlock()
    let l:indent = matchstr(getline('.'), '^\s*')
    let l:col = col('.')

    " parte izquierda y derecha
    let l:left  = getline('.')[0 : l:col-2]
    let l:right = getline('.')[l:col-1 :]

    " reemplazar línea actual
    call setline('.', l:left)

    " insertar abajo
    call append(line('.'), [
                \ l:indent . repeat(' ', &shiftwidth),
                \ l:indent . l:right
                \ ])

    " mover cursor al bloque
    call cursor(line('.')+1, len(l:indent)+&shiftwidth+1)

    startinsert
endfunction
nnoremap n viw
nnoremap a i
inoremap <Tab><Space> <Esc>o
inoremap <Tab><CR> <Esc><Right>:call SmartSplitBlock()<CR>
nnoremap m :tabNext<CR>
vnoremap o <Esc>:tabnew<CR>

function! JumpLine()

    let l:first = line('w0')
    let l:last  = line('w$')

    let l:labels = split('abcdefghijklmnopqrstuvwxyzVWXYZ', '\zs')

    let l:map = {}

    let l:id = 1
    let l:i = 0

    " limpiar signs anteriores
    execute 'sign unplace * group=jumpgroup'

    " =========================
    " DIBUJAR LETRAS
    " =========================
    for l:num in range(l:first, l:last)

        if l:i >= len(l:labels)
            break
        endif

        if foldclosed(l:num) != -1
            continue
        endif

        let l:char = l:labels[l:i]

        execute 'sign define JumpSign' . l:i .
                    \ ' text=' . l:char .
                    \ ' texthl=Search'

        execute 'sign place ' . l:id .
                    \ ' line=' . l:num .
                    \ ' name=JumpSign' . l:i .
                    \ ' group=jumpgroup buffer=' . bufnr('%')

        let l:map[l:char] = l:num

        let l:id += 1
        let l:i += 1
    endfor

    redraw
    echo "1 letra = saltar | 2 letras = seleccionar rango"

    " =========================
    " PRIMERA TECLA
    " =========================
    let l:key1 = nr2char(getchar())

    if !has_key(l:map, l:key1)
        execute 'sign unplace * group=jumpgroup'
        redraw
        return
    endif

    let l:start_line = l:map[l:key1]

    redraw
    " =========================
    " SOLO SALTO
    " =========================
    execute l:start_line
    execute 'sign unplace * group=jumpgroup'
endfunction



function! RangeJumpOrSelect()

    let l:first = line('w0')
    let l:last  = line('w$')

    let l:labels = split('abcdefghijklmnopqrstuvwxyzVWXYZ', '\zs')

    let l:map = {}

    let l:id = 1
    let l:i = 0

    " limpiar signs anteriores
    execute 'sign unplace * group=jumpgroup'

    " =========================
    " DIBUJAR LETRAS
    " =========================
    for l:num in range(l:first, l:last)

        if l:i >= len(l:labels)
            break
        endif

        if foldclosed(l:num) != -1
            continue
        endif

        let l:char = l:labels[l:i]

        execute 'sign define JumpSign' . l:i .
                    \ ' text=' . l:char .
                    \ ' texthl=Search'

        execute 'sign place ' . l:id .
                    \ ' line=' . l:num .
                    \ ' name=JumpSign' . l:i .
                    \ ' group=jumpgroup buffer=' . bufnr('%')

        let l:map[l:char] = l:num

        let l:id += 1
        let l:i += 1
    endfor

    redraw
    echo "1 letra = saltar | 2 letras = seleccionar rango"

    " =========================
    " PRIMERA TECLA
    " =========================
    let l:key1 = nr2char(getchar())

    if !has_key(l:map, l:key1)
        execute 'sign unplace * group=jumpgroup'
        redraw
        return
    endif

    let l:start_line = l:map[l:key1]

    redraw
    echo "segunda letra para rango (ESC cancela)"

    " =========================
    " ESPERAR SEGUNDA TECLA
    " =========================
    let l:c = getchar()

    " ESC => solo saltar
    if l:c == 27
        execute 'sign unplace * group=jumpgroup'
        execute l:start_line
        redraw
        return
    endif

    let l:key2 = nr2char(l:c)

    " =========================
    " LIMPIAR SIGNS
    " =========================
    execute 'sign unplace * group=jumpgroup'
    redraw

    " =========================
    " SOLO SALTO
    " =========================
    if !has_key(l:map, l:key2)
        execute l:start_line
        return
    endif

    " =========================
    " RANGO VISUAL
    " =========================
    let l:end_line = l:map[l:key2]

    if l:start_line > l:end_line
        let [l:start_line, l:end_line] =
                    \ [l:end_line, l:start_line]
    endif

    " mover al inicio
    call cursor(l:start_line, 1)

    " iniciar visual line
    normal! V

    " extender selección
    call cursor(l:end_line, 1)

endfunction

nnoremap f :call RangeJumpOrSelect()<CR>
vnoremap f <Esc>:call RangeJumpOrSelect()<CR>


function! JumpSearch()

    let l:query = g:input_resultado
    if empty(l:query)
        return
    endif

    let l:labels = split('abcdefghijklmnopqrstuvwxyzMBNOKG', '\zs')

    let l:first = line('w0')
    let l:last  = line('w$')

    let l:matches = {}
    let l:sign_id = 1
    let l:i = 0

    " limpiar
    execute 'sign unplace * group=jumpsearch'
    call clearmatches()

    " recorrer líneas visibles
    for l:num in range(l:first, l:last)

        let l:line = getline(l:num)
        let l:start = 0

        while 1

            let l:pos = match(l:line, l:query, l:start)

            if l:pos == -1
                break
            endif

            if l:i >= len(l:labels)
                break
            endif

            let l:char = l:labels[l:i]

            " guardar posición
            let l:matches[l:char] = [l:num, l:pos + 1]

            " resaltar coincidencia
            call matchaddpos(
                        \ 'Search',
                        \ [[l:num, l:pos + 1, strlen(l:query)]],
                        \ 10
                        \ )

            " crear sign
            execute 'sign define JumpSearchSign' . l:i .
                        \ ' text=' . l:char .
                        \ ' texthl=ErrorMsg'

            execute 'sign place ' . l:sign_id .
                        \ ' line=' . l:num .
                        \ ' name=JumpSearchSign' . l:i .
                        \ ' group=jumpsearch buffer=' . bufnr('%')

            let l:i += 1
            let l:sign_id += 1

            let l:start = l:pos + strlen(l:query)

        endwhile
    endfor

    redraw
    echo "Letra para saltar: "

    let l:key = nr2char(getchar())

    " limpiar
    execute 'sign unplace * group=jumpsearch'
    call clearmatches()
    redraw

    if has_key(l:matches, l:key)

        let [l:line, l:col] = l:matches[l:key]

        call cursor(l:line, l:col)

    endif

endfunction
function! BuscarMode()
    botright 1new
    setlocal buftype=nofile	 
    setlocal bufhidden=wipe	 
    setlocal noswapfile
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>
    startinsert
endfunction

nnoremap j :call BuscarMode()<CR>
vnoremap j <Esc>:call BuscarMode()<CR>
function! OpenExplorerInNewTab()
    let l:dir = expand('%:p:h')

    tabnew
    execute 'Ex ' . fnameescape(l:dir)
endfunction

nnoremap l <Esc>:call OpenExplorerInNewTab()<CR>
function! CrearInput()
    " 1. Crear la ventana
    botright 1new
    
    " 2. Configuración de comportamiento
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    
    " 3. Mapear la tecla Space solo para este búfer
    " Usamos <buffer> para que el espacio siga funcionando normal fuera de aquí
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>:call RangeJumpOrSelect()<CR>
    
    " 4. Entrar en modo insertar automáticamente
    startinsert
endfunction

function! CrearInputSingle()
    " 1. Crear la ventana
    botright 1new
    
    " 2. Configuración de comportamiento
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    
    " 3. Mapear la tecla Space solo para este búfer
    " Usamos <buffer> para que el espacio siga funcionando normal fuera de aquí
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>:call JumpLine()<CR>
    
    " 4. Entrar en modo insertar automáticamente
    startinsert
endfunction


function! CrearInputDired()
    " 1. Crear la ventana
    botright 1new
    
    " 2. Configuración de comportamiento
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    
    " 3. Mapear la tecla Space solo para este búfer
    " Usamos <buffer> para que el espacio siga funcionando normal fuera de aquí
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>:call NetrwCreateDir()<CR>
    
    " 4. Entrar en modo insertar automáticamente
    startinsert
endfunction


function! CrearInputFile()
    " 1. Crear la ventana
    botright 1new
    
    " 2. Configuración de comportamiento
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    
    " 3. Mapear la tecla Space solo para este búfer
    " Usamos <buffer> para que el espacio siga funcionando normal fuera de aquí
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>:call NetrwCreateFile()<CR>
    
    " 4. Entrar en modo insertar automáticamente
    startinsert
endfunction


function! CrearInput()
    " 1. Crear la ventana
    botright 1new
    
    " 2. Configuración de comportamiento
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    
    " 3. Mapear la tecla Space solo para este búfer
    " Usamos <buffer> para que el espacio siga funcionando normal fuera de aquí
    inoremap <buffer> <Space> <Esc>:call FinalizarInput()<CR>:call RangeJumpOrSelect()<CR>
    
    " 4. Entrar en modo insertar automáticamente
    startinsert
endfunction

function! WordMove()
    nnoremap <BS> w
    nnoremap <Space> b
endfunction
function! FinalizarInput()
    " Guardar la primera línea en una variable global
    let g:input_resultado = getline(1)
    let @/ = g:input_resultado
    nnoremap <BS> n
    nnoremap <Space> N
    q!
endfunction
" Guardar la posición actual en la marca 'a'
nnoremap d ma
nnoremap c V`a

nnoremap b <C-w><C-w>
vnoremap <BS> <Esc><C-d>v
vnoremap <Space> <Esc><C-u>v
nnoremap e :call WordMove()<CR>
function! NetrwCreateDir()
    let l:name = g:input_resultado

    if empty(l:name)
        return
    endif

    let l:path = b:netrw_curdir . '/' . l:name

    call mkdir(l:path, "p")

    " refrescar netrw
    edit
endfunction
autocmd FileType netrw nnoremap <buffer> w :call CrearInputDired()<CR>

function! NetrwCreateFile()

    let l:name = g:input_resultado
    if empty(l:name)
        return
    endif

    let l:path = b:netrw_curdir . '/' . l:name

    " crear archivo vacío
    call writefile([], l:path)

    " refrescar netrw
    edit
endfunction
autocmd FileType netrw nnoremap <buffer> e :call CrearInputFile()<CR>
autocmd FileType netrw nnoremap <buffer> q :q<CR>
autocmd FileType netrw nnoremap <buffer> o <Down>
autocmd FileType netrw nnoremap <buffer> p k
autocmd FileType netrw nnoremap <buffer> a :let @+ = expand('%:p:h') \| echo @+<CR>
let g:netrw_banner = 0
function! OpenOldFilesBuffer()
    redir => l:output
    silent oldfiles
    redir END

    enew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile

    let l:lines = split(l:output, "\n")

    " Quitar números y conservar solamente archivos existentes
    call map(l:lines, {_, line -> substitute(line, '^\s*\d\+:\s*', '', '')})
    call filter(l:lines, {_, line -> filereadable(expand(line))})

    call setline(1, l:lines)

    nnoremap <buffer> <CR> :call <SID>OpenSelectedOldFile()<CR>
endfunction

" Crear un grupo de resaltado que herede el fondo de Normal y el texto de Normal
highlight MiniPickFloat ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE

function! s:OpenSelectedOldFile()
    let l:file_path = expand(getline('.'))

    if empty(l:file_path)
        echo "No hay una ruta de archivo válida."
        return
    endif

    if !filereadable(l:file_path)
        echo "El archivo ya no existe: " . l:file_path
        return
    endif

    execute 'edit ' . fnameescape(l:file_path)
endfunction
command! OldFilesBuf call OpenOldFilesBuffer()
vnoremap k <Esc>:OldFilesBuf<CR>
function! SelectBetweenChars(caracter)
    if strlen(a:caracter) < 2
        echo "Se necesitan dos caracteres"
        return
    endif

    let l:char_back = a:caracter[0]
    let l:char_forward = a:caracter[1]

    let l:save_cursor = getpos('.')

    " Buscar hacia atrás
    let l:back_pos = searchpos('\V' . escape(l:char_back, '\'), 'bW')

    if l:back_pos[0] == 0
        echo "No se encontró '" . l:char_back . "' hacia atrás"
        call setpos('.', l:save_cursor)
        return
    endif

    let l:start_line = l:back_pos[0]
    let l:start_col = l:back_pos[1] + 1

    " Volver al cursor original
    call setpos('.', l:save_cursor)

    " Buscar hacia adelante
    let l:forward_pos = searchpos('\V' . escape(l:char_forward, '\'), 'W')

    if l:forward_pos[0] == 0
        echo "No se encontró '" . l:char_forward . "' hacia adelante"
        call setpos('.', l:save_cursor)
        return
    endif

    let l:end_line = l:forward_pos[0]
    let l:end_col = l:forward_pos[1] - 1

    " Crear selección visual
    call cursor(l:start_line, l:start_col)
    execute "normal! v"
    call cursor(l:end_line, l:end_col)
endfunction

nnoremap <silent> vl :call SelectBetweenChars("''")<CR>
nnoremap <silent> vc :call SelectBetweenChars('""')<CR>
function! RemoveLastChar(str)
    let chars = split(a:str, '\zs')
    if !empty(chars)
        call remove(chars, -1)
    endif
    return join(chars, '')
endfunction

function! FuzzyScore(word, query)
    let l:query = tolower(a:query)
    let l:word = tolower(a:word)

    let score = 0
    let pos = 0
    let prev_idx = -2

    for c in split(l:query, '\zs')
        let pos = match(l:word, c, pos)

        if pos < 0
            return -1
        endif

        " Coincidencia consecutiva
        if pos == prev_idx + 1
            let score += 10
        else
            let score += 1
        endif

        " Bonificación al inicio de una palabra
        if pos == 0 || l:word[pos - 1] =~ '\s'
            let score += 8
        endif

        let prev_idx = pos
        let pos += 1
    endfor

    return score
endfunction

function! InteractivePicker(nombres, titlex)
    let query = ''
    let selected_idx = 0

    let win_width = 45
    let win_height = 12
    let start_col = (&columns - win_width) / 2
    let start_line = (&lines - win_height) / 2

    let winid = popup_create(['Buscar: '], {
        \ 'line': start_line > 0 ? start_line : 1,
        \ 'col': start_col > 0 ? start_col : 1,
        \ 'minwidth': win_width,
        \ 'maxheight': win_height,
        \ 'padding': [0, 1, 0, 1],
        \ 'border': [1, 1, 1, 1],
        \ 'title': a:titlex,
        \ 'highlight' : 'MiniPickFloat',
        \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ })

    " Forzar repintado inicial para asegurar que el popup aparezca inmediatamente
    redraw

    while 1
        let scored_results = []
        if empty(query)
            let scored_results = map(copy(a:nombres), '{"name": v:val, "score": 0}')
        else
            for nombre in a:nombres
                let s = FuzzyScore(nombre, query)
                if s >= 0
                    call add(scored_results, {'name': nombre, 'score': s})
                endif
            endfor
            call sort(scored_results, {a, b -> b.score - a.score})
        endif

        let results = map(copy(scored_results), 'v:val.name')

        if empty(results)
            let selected_idx = 0
            let display_list = ['', '[ No hay coincidencias ]']
        else
            if selected_idx >= len(results)
                let selected_idx = len(results) - 1
            endif
            if selected_idx < 0
                let selected_idx = 0
            endif
            
            let display_list = ['   ']
            for i in range(len(results))
                if i == selected_idx
                    call add(display_list, '> ' . results[i])
                else
                    call add(display_list, '  ' . results[i])
                endif
            endfor
        endif

        call popup_settext(winid, ['> ' . query . '_'] + display_list)
        
        if !empty(results)
            call win_execute(winid, 'call cursor(' . (selected_idx + 3) . ', 1)')
        endif

        " Repintar para reflejar cambios en tiempo real antes de esperar la siguiente tecla
        redraw

        let char = getchar()

        if char == "\<Esc>" || char == 27 || char == "\<C-c>"
            call popup_close(winid)
            return ''
        elseif char == "\<CR>" || char == 13
            call popup_close(winid)
            return !empty(results) ? results[selected_idx] : ''
        elseif char == "\<BS>" || char == "\<C-h>" || char == 8 || char == 127
            let query = RemoveLastChar(query)
        elseif char == "\<C-u>"
            let query = ''
        elseif char == "\<Down>" || char == "\<C-n>"
            if !empty(results) && selected_idx < len(results) - 1
                let selected_idx += 1
            endif
        elseif char == "\<Up>" || char == "\<C-p>"
            if !empty(results) && selected_idx > 0
                let selected_idx -= 1
            endif
        elseif type(char) == 0
            let str_char = nr2char(char)
            " Permitir caracteres imprimibles extendidos y ASCII (>= 32)
            if char >= 32
                let query .= str_char
            endif
        endif
    endwhile
endfunction



function! NewRama(git_root)
    botright 1new
    setlocal buftype=nofile	 
    setlocal bufhidden=wipe	 
    setlocal noswapfile
    let g:git_root = a:git_root
    inoremap <buffer> <Space> <Esc>:call CreateRamaGit()<CR>
    startinsert
endfunction

function! NewCommit(git_root)
    botright 1new
    setlocal buftype=nofile	 
    setlocal bufhidden=wipe	 
    setlocal noswapfile
    let g:git_root = a:git_root
    inoremap <buffer> <Space> <Esc>:call CreateCommitGit()<CR>
    startinsert
endfunction
function! CreateCommitGit()
    let l:git_root = substitute(g:git_root, '[\r\n]', '', 'g')
    let namerama = getline(1)
    q!
    call system('git -C ' . shellescape(l:git_root) . ' commit -am ' . namerama)
    echomsg "new commit creado : " . namerama
endfunction

function! CreateRamaGit()
    let l:git_root = substitute(g:git_root, '[\r\n]', '', 'g')
    let namerama = getline(1)
    q!
    call system('git -C ' . shellescape(l:git_root) . ' checkout -b ' . namerama)
    echomsg "nueva rama  creada : " . namerama
endfunction
function! GetGitFiles(git_root)
    "limpiar git_root
    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')
    let l:raw_files = systemlist(
        \ 'git -C ' . shellescape(l:git_root) . ' ls-files'
        \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg a:git_root 
        echohl None
        return
    endif

    " Limpiar archivos
    let g:nombres_ls_git = filter(
        \ map(l:raw_files, 'trim(v:val)'),
        \ '!empty(v:val)'
        \ )

    if empty(g:nombres_ls_git)
        echomsg "No hay archivos seguidos por Git."
        return
    endif
    " creamos un picker para los git-ls
    let elegido = InteractivePicker(g:nombres_ls_git, ' Git ls files ')
    if !empty(elegido)
        call system('git -C ' . shellescape(l:git_root) . ' rm --cached ' . elegido)
        echomsg 'removido : ' . elegido
    endif
endfunction

" Función auxiliar para intentar cambiar de rama (soporta git switch y fallback a checkout)
function! TrySwitchBranch(git_root, branch_name)
    " Intentar con git switch
    let l:output = system('git -C ' . shellescape(a:git_root) . ' switch ' . shellescape(a:branch_name) . ' 2>&1')
    if v:shell_error == 0
        echomsg "Cambiado a la rama: " . a:branch_name
        return [1, ""]
    endif

    " Fallback a git checkout si git switch falla
    let l:output_checkout = system('git -C ' . shellescape(a:git_root) . ' checkout ' . shellescape(a:branch_name) . ' 2>&1')
    if v:shell_error == 0
        echomsg "Cambiado a la rama: " . a:branch_name
        return [1, ""]
    endif

    " Si ambos fallan, devolvemos el mensaje de error limpio
    return [0, substitute(l:output, '[\r\n]', ' ', 'g')]
endfunction

" Función principal para seleccionar y cambiar de rama (equivalente a on_select_branch)
function! GitSelectBranch(git_root,raw_branch)
    " 1. Limpiar el nombre de la rama (quitar '*' y espacios)
    let l:selected_branch = substitute(a:raw_branch, '\*', '', 'g')
    let l:selected_branch = substitute(l:selected_branch, '^\s*\(.\{-}\)\s*$', '\1', '')

    " Si es remota (ej. remotes/origin/feature), tomar solo la última parte
    if stridx(l:selected_branch, "remotes/") == 0
        let l:parts = split(l:selected_branch, "/")
        if len(l:parts) > 2
            let l:selected_branch = l:parts[-1]
        endif
    endif

    " 2. Intentar hacer el switch inicial
    let [l:success, l:error_msg] = TrySwitchBranch(a:git_root, l:selected_branch)

    if !l:success
        " 3. Verificar si el fallo es por cambios locales no guardados
        if stridx(l:error_msg, "would be overwritten") >= 0 || stridx(l:error_msg, "local changes") >= 0
            let l:choice = confirm("Los cambios locales serían sobrescritos. ¿Desea hacer un 'stash' y cambiar de rama?", "&Sí\n&No", 2)
            
            if l:choice == 1
                try
                    " 4. Hacer stash push
                    let l:stash_out = system('git -C ' . shellescape(a:git_root) . ' stash push -m "Auto-stash por Vimscript Git"')
                    if v:shell_error != 0
                        throw "Error al hacer stash: " . l:stash_out
                    endif

                    " 5. Reintentar switch
                    let [l:success_retry, l:err_retry] = TrySwitchBranch(a:git_root, l:selected_branch)
                    
                    if l:success_retry
                        " 6. Aplicar stash pop en la nueva rama
                        let l:pop_out = system('git -C ' . shellescape(a:git_root) . ' stash pop')
                        redraw!
                        echomsg "¡Cambiado a '" . l:selected_branch . "' y cambios restaurados con éxito!"
                    else
                        echohl ErrorMsg | echomsg "No se pudo cambiar de rama: " . l:err_retry | echohl None
                    endif
                catch
                    echohl ErrorMsg | echomsg v:exception | echohl None
                endtry
            endif
        else
            echohl ErrorMsg | echomsg "No se pudo cambiar de rama: " . l:error_msg | echohl None
        endif
    endif
endfunction

function! GetRamasGit(git_root)
    "limpiar git_root
    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')
    let l:raw_files = systemlist(
        \ 'git -C ' . shellescape(l:git_root) . ' branch -a'
        \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg l:git_root 
        echohl None
        return
    endif

    " Limpiar archivos
    let g:nombres_ls_git = filter(
        \ map(l:raw_files, 'trim(v:val)'),
        \ '!empty(v:val)'
        \ )

    if empty(g:nombres_ls_git)
        echomsg "No hay archivos seguidos por Git."
        return
    endif
    " creamos un picker para los git-ls
    let elegido = InteractivePicker(g:nombres_ls_git, ' Git ls files ')
    if !empty(elegido)
        call GitSelectBranch(l:git_root , elegido)
    endif
endfunction

function! GitCommitLs(commit_hash, git_root)

    "limpiar git_root
    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')
    let l:raw_files = systemlist(
        \ "git -C " . shellescape(l:git_root) . " show --name-only --pretty= " . a:commit_hash
        \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg l:git_root 
        echohl None
        return
    endif

    " Limpiar archivos
    let g:nombres_ls_git = filter(
        \ map(l:raw_files, 'trim(v:val)'),
        \ '!empty(v:val)'
        \ )

    if empty(g:nombres_ls_git)
        echomsg "No hay archivos seguidos por Git."
        return
    endif
    " creamos un picker para los git-ls
    let elegido = InteractivePicker(g:nombres_ls_git, ' ls Current Commit ')
    if !empty(elegido)
        echomsg elegido
    endif
endfunction

function! OpenFileAtCommit(commit_hash, git_root)
    " Guardar el tipo de archivo ANTES de cambiar de buffer
    let l:original_filetype = &filetype

    " Obtener la ruta del archivo actual
    let l:current_file = substitute(expand('%:p'), '[\r\n]', '', 'g')
    let l:current_dir = substitute(expand('%:p:h'), '[\r\n]', '', 'g')

    if empty(l:current_file)
        echohl ErrorMsg
        echomsg "No hay un archivo activo guardado en disco."
        echohl None
        return
    endif

    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')

    " Obtener la ruta relativa dentro del repositorio
    let l:rel_path = substitute(
                \ l:current_file,
                \ '^' . escape(l:git_root, '\'),
                \ '',
                \ ''
                \ )

    " Eliminar / inicial si existe
    let l:rel_path = substitute(l:rel_path, '^/', '', '')

    " Verificar si el archivo existía en ese commit
    let l:check_file = system(
                \ 'git -C ' . shellescape(l:git_root)
                \ . ' cat-file -e '
                \ . shellescape(a:commit_hash . ':' . l:rel_path)
                \ . ' 2>/dev/null'
                \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg "El archivo no existía en el commit " . a:commit_hash . "."
        echohl None
        return
    endif

    " Obtener contenido del archivo
    let l:content = systemlist(
                \ 'git -C ' . shellescape(l:git_root)
                \ . ' show '
                \ . shellescape(a:commit_hash . ':' . l:rel_path)
                \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg "No se pudo leer el contenido del commit."
        echohl None
        return
    endif

    " Abrir nueva pestaña
    tabnew

    " Configurar como buffer temporal
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile

    " Cargar contenido
    call setline(1, l:content)

    " Mantener el nombre original para preservar la extensión
    let l:file_basename = fnamemodify(l:current_file, ':t')

    execute 'file ' . fnameescape(
                \ l:file_basename . ' @ ' . a:commit_hash
                \ )

    " Restaurar filetype del archivo original
    if !empty(l:original_filetype)
        execute 'setlocal filetype=' . l:original_filetype
    endif

    " Forzar activación de syntax highlighting
    syntax enable

    " Solo lectura
    setlocal nomodifiable
    setlocal readonly

    echomsg "Archivo cargado con éxito para el commit: " . a:commit_hash
endfunction
function! RestoreAllAtCommit(commit_hash, git_root)
    " 1. Obtener la ruta del directorio actual y limpiarla
    let l:current_dir = substitute(expand('%:p:h'), '[\r\n]', '', 'g')

    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')

    " 3. Cuadro de diálogo de confirmación (¡Peligro de sobrescritura masiva!)
    let l:choice = confirm("¿Estás seguro de restaurar TODO el proyecto al commit " . a:commit_hash . "? Se perderán los cambios no guardados en los archivos afectados.", "&Sí\n&No", 2)
    
    if l:choice != 1
        return
    endif

    " 4. Ejecutar git checkout para restaurar todo el directorio raíz con ese commit
    " Usamos '.' al final para indicar todo el repositorio
    let l:output = system('git -C ' . shellescape(l:git_root) . ' checkout ' . shellescape(a:commit_hash) . ' -- . 2>&1')

    if v:shell_error == 0
        echomsg "¡Proyecto restaurado por completo , recargue los buffers !"
    else
        let l:clean_error = substitute(l:output, '[\r\n]', ' ', 'g')
        echohl ErrorMsg | echomsg "Error Git: " . l:clean_error | echohl None
    endif
endfunction
function! GitCommitOptions(nombres, git_root, commit_hash)
    let elegido = InteractivePicker(a:nombres, ' Commit Option ')
    if !empty(elegido)
        if elegido == "ver files commit"
            call GitCommitLs(a:commit_hash,a:git_root)
        elseif elegido == "open commit in buffer"
            call OpenFileAtCommit(a:commit_hash,a:git_root)
        elseif elegido == "copy commit to current file"
            call RestoreFileAtCommit(a:commit_hash,a:git_root)
        elseif elegido == "copy commit to all files"
            call RestoreAllAtCommit(a:commit_hash,a:git_root)
        endif

    endif
endfunction
function! RestoreFileAtCommit(commit_hash, git_root)
    " 1. Obtener la ruta del archivo actual y limpiarla de saltos de línea
    let l:current_file = substitute(expand('%:p'), '[\r\n]', '', 'g')
    let l:current_dir = substitute(expand('%:p:h'), '[\r\n]', '', 'g')

    if empty(l:current_file)
        echohl ErrorMsg | echomsg "No hay un archivo activo guardado en disco." | echohl None
        return
    endif

    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')

    let l:rel_path = substitute(l:current_file, '^' . l:git_root . '/', '', '')

    " 4. Ejecutar git checkout para traer la versión del commit al archivo actual
    let l:output = system('git -C ' . shellescape(l:git_root) . ' checkout ' . shellescape(a:commit_hash) . ' -- ' . shellescape(l:rel_path) . ' 2>&1')

    if v:shell_error == 0
        " 5. Recargar el archivo en Vim para que muestre el contenido actualizado del disco
        silent edit!
        echomsg "¡Current file actualizado con éxito al commit " . a:commit_hash . "!"
    else
        " Mostrar el error exacto si algo falla
        let l:clean_error = substitute(l:output, '[\r\n]', ' ', 'g')
        echohl ErrorMsg | echomsg "Error Git: " . l:clean_error | echohl None
    endif
endfunction
let g:commit_options= [
    \ 'ver files commit',
   \ 'open commit in buffer',
    \ 'copy commit to current file',
    \ 'copy commit to all files',
    \ ]

function! ShowCommits(git_root)
    "limpiar git_root
    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')
    let l:raw_files = systemlist(
        \ "git -C " . shellescape(l:git_root) . " log --decorate --oneline | awk '/\\(/ {c++; if(c==2) exit} {print}'"
        \ )

    if v:shell_error != 0
        echohl ErrorMsg
        echomsg l:git_root 
        echohl None
        return
    endif

    " Limpiar archivos
    let g:nombres_ls_git = filter(
        \ map(l:raw_files, 'trim(v:val)'),
        \ '!empty(v:val)'
        \ )

    if empty(g:nombres_ls_git)
        echomsg "No hay archivos seguidos por Git."
        return
    endif
    " creamos un picker para los git-ls
    let elegido = InteractivePicker(g:nombres_ls_git, ' Commits Current Branch ')
    if !empty(elegido)
        let commit_hash = split(elegido)[0]
        call GitCommitOptions(g:commit_options,l:git_root , commit_hash)
    endif
endfunction
let g:git_commands = [
    \ 'ver ramas',
    \ 'ver commits',
    \ 'git ls',
    \ 'new rama',
    \ 'new commit',
    \ 'github',
    \ 'git add'
    \ ]
function! s:GitPush(git_root)
    " Obtener la rama actual
    let l:rama_actual = substitute(system('git -C ' . shellescape(a:git_root) . ' branch --show-current 2>/dev/null'), '^\s*\(.\{-}\)\s*$', '\1', '')
    if empty(l:rama_actual)
        " Fallback por si branch --show-current falla en versiones muy antiguas de git
        let l:rama_actual = substitute(system('git -C ' . shellescape(a:git_root) . ' symbolic-ref --short HEAD 2>/dev/null'), '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
    let l:rama_actual = substitute(l:rama_actual, '[\r\n[:space:]]*$', '', 'g')

    if empty(l:rama_actual)
        echohl ErrorMsg | echomsg "No se pudo detectar la rama actual." | echohl None
        return
    endif

    " Ejecutar git push -u origin <rama>
    let l:output = system('git -C ' . shellescape(a:git_root) . ' push -u origin ' . shellescape(l:rama_actual) . ' 2>&1')
    if v:shell_error == 0
        redraw!
        echomsg "¡GitHub publicado con éxito en la rama '" . l:rama_actual . "'!"
    else
        let l:clean_error = substitute(l:output, '[\r\n]', ' ', 'g')
        echohl ErrorMsg | echomsg "Error al hacer push: " . l:clean_error | echohl None
    endif
endfunction

function! s:GitUrl(git_root)
    " Pedir el link usando la línea de comandos de Vim (equivalente a show_input_panel)
    let l:repo_url = input("Link de GitHub: ")
    redraw!

    if empty(l:repo_url)
        echomsg "Operación cancelada."
        return
    endif

    " Agregar el remote origin
    let l:output = system('git -C ' . shellescape(a:git_root) . ' remote add origin ' . shellescape(l:repo_url) . ' 2>&1')
    if v:shell_error == 0
        call s:GitPush(a:git_root)
    else
        let l:clean_error = substitute(l:output, '[\r\n]', ' ', 'g')
        echohl ErrorMsg | echomsg "Error al crear el remote: " . l:clean_error | echohl None
    endif
endfunction

function! GitGithubPublish(git_root)
    let l:git_root = substitute(a:git_root, '[\r\n]', '', 'g')

    " 1. Verificar si ya existe un remote 'origin'
    let l:resultado = substitute(system('git -C ' . shellescape(l:git_root) . ' remote get-url origin 2>/dev/null'), '^\s*\(.\{-}\)\s*$', '\1', '')

    if v:shell_error == 0 && !empty(l:resultado)
        " El remoto ya existe, mostrar cuadro de diálogo interactivo (confirm)
        let l:mensaje = "El remote 'origin' ya existe:\n" . l:resultado . "\n\n¿Deseas usar este link?"
        let l:choice = confirm(l:mensaje, "&Sí, usar este\n&No, cambiar", 1)

        if l:choice == 1
            " Usar el existente y hacer push
            call s:GitPush(l:git_root)
        else
            " Eliminar el remote actual para configurar uno nuevo
            let l:remove_out = system('git -C ' . shellescape(l:git_root) . ' remote remove origin 2>&1')
            if v:shell_error == 0
                call s:GitUrl(l:git_root)
            else
                echohl ErrorMsg | echomsg "Error al eliminar el remote anterior." | echohl None
            endif
        endif
    else
        " El remoto 'origin' no está configurado, pedir directamente el link
        call s:GitUrl(l:git_root)
    endif
endfunction
let g:git_rox = 'none'
function! GitAddNetwr()
    if g:git_rox == 'none'
        echomsg 'git root base = none'
    else 
        let l:pathx = expand('%:p:h')
        let l:select_file = l:pathx . '/' . expand('<cfile>')
        let l:git_root = substitute(g:git_rox, '[\r\n]', '', 'g')

        " Obtener la ruta relativa dentro del repositorio
        let l:rel_path = substitute(
                    \ l:select_file,
                    \ '^' . escape(l:git_root, '\'),
                    \ '',
                    \ ''
                    \ )

        let l:rel_path = substitute(l:rel_path, '^/', '', '')
        let l:output = system('git -C ' . shellescape(l:git_root) . ' add ' . l:rel_path)
        if v:shell_error == 0
            redraw!
            echomsg 'file agregado : ' . l:rel_path
        else
            let l:clean_error = substitute(l:output, '[\r\n]', ' ', 'g')
            echohl ErrorMsg | echomsg "Error al agregar: " . l:clean_error | echohl None
        endif
    endif
endfunction
autocmd FileType netrw nnoremap <buffer> k :call GitAddNetwr()<CR>

function! GitTools(nombres, git_root)
    let elegido = InteractivePicker(a:nombres, ' Git Tool')

    if !empty(elegido)
        if elegido == "git ls"
            call GetGitFiles(a:git_root)
        elseif elegido == "ver commits"
            call ShowCommits(a:git_root)
        elseif elegido == "ver ramas"
            call GetRamasGit(a:git_root)
        elseif elegido == "new commit"
            call NewCommit(a:git_root)
        elseif elegido == "github"
            call GitGithubPublish(a:git_root)
        elseif elegido == "git add"
            let g:git_rox = a:git_root
            echomsg 'add file "k" keymap'
            call OpenExplorerInNewTab()
        elseif elegido == "new rama"
            call NewRama(a:git_root)
        endif
    endif
endfunction

function! CheckAndInitGit()
    " Obtener el directorio del archivo actual
    let l:current_dir = expand('%:p:h')
    
    " Verificar si existe un repositorio git
    let l:git_root = system('git -C ' . shellescape(l:current_dir) . ' rev-parse --show-toplevel 2>/dev/null')
    let l:git_root = substitute(l:git_root, '^\s*\(.\{-}\)\s*$', '\1', '') " trim

    if empty(l:git_root)
        " Preguntar mediante un cuadro de confirmación
        let l:choice = confirm("No hay repositorio Git creado. ¿Desea inicializar Git?", "&Sí\n&No", 2)
        
        if l:choice == 1
            " Inicializar git
            call system('git -C ' . shellescape(l:current_dir) . ' init')
            call GitTools(g:git_commands, l:git_root)
            echomsg "Repositorio Git inicializado con éxito."
        endif
    else
        echomsg "Git root: " . l:git_root
        call GitTools(g:git_commands , l:git_root)
    endif
endfunction

nnoremap k :call CheckAndInitGit()<CR>
function! CustomHotkey()
    inoremap <buffer> <CR> <Esc>:call SendFirstLineFromBelowToTerm()<CR>a
    nnoremap <buffer> <CR> :call SendFirstLineFromBelowToTerm()<CR>a
endfunction
vnoremap x <Esc>:lcd %:h<CR>:tabnew<CR>:term<CR><C-w>j:resize 3<CR>:call CustomHotkey()<CR>

function! SendFirstLineFromBelowToTerm()
  " Ir a la ventana de abajo
  wincmd j
  let l:cmd = getline('.')
  wincmd k
  " Obtener el job
  let bnum = winbufnr(win_getid())
  call term_sendkeys(bnum, l:cmd . "\n")
  startinsert

endfunction

inoremap <Tab>j <Esc>vUa
nnoremap gs ggVG 
nnoremap gd G 
nnoremap gr gg 

function! InteractivePickerBuffer(items)
    let query = ''
    let selected_idx = 0

    let win_width = 55
    let win_height = 12
    let start_col = (&columns - win_width) / 2
    let start_line = (&lines - win_height) / 2

    let winid = popup_create(['Buscar: '], {
        \ 'line': start_line > 0 ? start_line : 1,
        \ 'col': start_col > 0 ? start_col : 1,
        \ 'minwidth': win_width,
        \ 'maxheight': win_height,
        \ 'padding': [0, 1, 0, 1],
        \ 'border': [1, 1, 1, 1],
        \ 'title': ' Buffers Picker ',
        \ 'highlight': 'MiniPickFloat',
        \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ })

    redraw

    while 1
        let scored_results = []
        if empty(query)
            let scored_results = map(copy(a:items), '{"name": v:val.text, "bufnr": v:val.bufnr, "score": 0}')
        else
            for item in a:items
                let s = FuzzyScore(item.text, query)
                if s >= 0
                    call add(scored_results, {'name': item.text, 'bufnr': item.bufnr, 'score': s})
                endif
            endfor
            call sort(scored_results, {a, b -> b.score - a.score})
        endif

        let results = scored_results

        if empty(results)
            let selected_idx = 0
            let display_list = ['', '[ No hay buffers coincidentes ]']
        else
            if selected_idx >= len(results)
                let selected_idx = len(results) - 1
            endif
            if selected_idx < 0
                let selected_idx = 0
            endif
            
            let display_list = ['   ']
            for i in range(len(results))
                if i == selected_idx
                    call add(display_list, '> ' . results[i].name)
                else
                    call add(display_list, '  ' . results[i].name)
                endif
            endfor
        endif

        call popup_settext(winid, ['Buscar: ' . query . '_'] + display_list)
        
        if !empty(results)
            call win_execute(winid, 'call cursor(' . (selected_idx + 3) . ', 1)')
        endif

        redraw

        let char = getchar()

        if char == "\<Esc>" || char == 27 || char == "\<C-c>"
            call popup_close(winid)
            return -1
        elseif char == "\<CR>" || char == 13
            call popup_close(winid)
            return !empty(results) ? results[selected_idx].bufnr : -1
        elseif char == "\<BS>" || char == "\<C-h>" || char == 8 || char == 127
            let query = RemoveLastChar(query)
        elseif char == "\<C-u>"
            let query = ''
        elseif char == "\<Down>" || char == "\<C-n>"
            if !empty(results) && selected_idx < len(results) - 1
                let selected_idx += 1
            endif
        elseif char == "\<Up>" || char == "\<C-p>"
            if !empty(results) && selected_idx > 0
                let selected_idx -= 1
            endif
        elseif type(char) == 0
            let str_char = nr2char(char)
            if char >= 32
                let query .= str_char
            endif
        endif
    endwhile
endfunction

function! PickBuffers()
    " Obteer la lista de buffers cargados que tienen un nombre válido
    let buffers = []
    for bufnr in range(1, bufnr('$'))
        if buflisted(bufnr)
            let name = bufname(bufnr)
            let name = empty(name) ? '[No Name]' : name
            " Guardamos tanto el texto legible como el número de buffer (bufnr)
            call add(buffers, {'bufnr': bufnr, 'text': bufnr . ': ' . name})
        endif
    endfor

    if empty(buffers)
        echo "No hay buffers abiertos"
        return
    endif

    let chosen_bufnr = InteractivePickerBuffer(buffers)

    " Si se seleccionó un buffer válido, cambiar a él en la ventana actual
    if chosen_bufnr != -1
        execute 'buffer ' . chosen_bufnr
    endif
endfunction

nnoremap t :call PickBuffers()<CR>

