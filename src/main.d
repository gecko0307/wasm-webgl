module main;

version(WebAssembly)
{
    import main_web;
}
else 
{
    import main_desktop;
}
