using System;
using Sjoerd.Miniaudio;

unsafe
{
    var version = Miniaudio.ma_version_string();
    Console.WriteLine(*version);
}