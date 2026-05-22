using System;
using Sjoerd.Miniaudio;

unsafe
{
    var version = Miniaudio.version_string();
    Console.WriteLine(*version);
}