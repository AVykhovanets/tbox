-- project
set_project("tbox")

-- version
set_version("1.5.1")

-- set warning all as error
set_warnings("all", "error")

-- set language: c99, c++11
set_languages("c99", "cxx11")

-- add defines to config.h
add_defines_h("$(prefix)_OS_$(OS)")

-- add undefines to config.h 
add_undefines_h("$(prefix)_TRACE_INFO_ONLY")
add_undefines_h("$(prefix)_EXCEPTION_ENABLE")
add_undefines_h("$(prefix)_MEMORY_UNALIGNED_ACCESS_ENABLE")
 
-- add defines for c files
add_defines("_GNU_SOURCE=1", "_REENTRANT")

-- disable some compiler errors
add_cxflags("-Wno-error=deprecated-declarations", "-fno-strict-aliasing")
add_mxflags("-Wno-error=deprecated-declarations", "-fno-strict-aliasing")

-- the debug mode
if is_mode("debug", "coverage") then
    
    -- enable the debug symbols
    set_symbols("debug")

    -- disable optimization
    set_optimize("none")

    -- add defines for debug
    add_defines("__tb_debug__")

    -- attempt to enable some checkers for pc
    if is_arch("i386", "x86_64") then
        add_cxflags("-fsanitize=address", "-ftrapv")
        add_mxflags("-fsanitize=address", "-ftrapv")
        add_ldflags("-fsanitize=address")
    end

    -- enable coverage
    if is_mode("coverage") then
        add_cxflags("--coverage")
        add_mxflags("--coverage")
        add_ldflags("--coverage")
    end
end

-- the release or profile is_mode
if is_mode("release", "profile") then

    -- the release mode
    if is_mode("release") then
        
        -- set the symbols visibility: hidden
        set_symbols("hidden")

        -- strip all symbols
        set_strip("all")

        -- fomit the frame pointer
        add_cxflags("-fomit-frame-pointer")
        add_mxflags("-fomit-frame-pointer")

    -- the profile mode
    else
    
        -- enable the debug symbols
        set_symbols("debug")

        -- enable gprof
        add_cxflags("-pg")
        add_ldflags("-pg")

    end

    -- for pc
    if is_arch("i386", "x86_64") or is_plat("windows") then
 
        -- enable fastest optimization
        set_optimize("fastest")

    -- for embed
    else
        -- enable smallest optimization
        set_optimize("smallest")
    end

    -- attempt to add vector extensions 
    add_vectorexts("sse2", "sse3", "ssse3", "mmx")
end

-- for embed
if not is_arch("i386", "x86_64") then

    -- add defines for small
    add_defines("__tb_small__")

    -- add defines to config.h
    add_defines_h("$(prefix)_SMALL")
end

-- for the windows platform (msvc)
if is_plat("windows") then 

    -- add some defines only for windows
    add_defines("NOCRYPT", "NOGDI")

    -- the release mode
    if is_mode("release") then

        -- link libcmt.lib
        add_cxflags("-MT") 

    -- the debug mode
    elseif is_mode("debug") then

        -- enable some checkers
        add_cxflags("-Gs", "-RTC1") 

        -- link libcmtd.lib
        add_cxflags("-MTd") 
    end

    -- no msvcrt.lib
    add_ldflags("-nodefaultlib:\"msvcrt.lib\"")
end

-- add option: demo
option("demo")
    set_enable(true)
    set_showmenu(true)
    set_category("option")
    set_description("Enable or disable the demo module")

-- add packages
add_pkgdirs("pkg") 

-- add projects
add_subdirs("src/tbox") 
if is_option("demo") then add_subdirs("src/demo") end
