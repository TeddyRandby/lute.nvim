function! ReloadAlpha()
lua << EOF
    for k in pairs(package.loaded) do 
        if k:match("^lute") then
            package.loaded[k] = nil
        end
    end
EOF
endfunction

nnoremap <Leader>vr :call ReloadAlpha()<CR>
nnoremap <Leader>vt :lua require("lute").run_file()<CR>
