using System;
using Sjoerd.Miniaudio;

unsafe
{
    var version = ma.version_string();
    Console.WriteLine(*version);
}