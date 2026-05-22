using System;
using System.Text;
using Sjoerd.Miniaudio;

unsafe static class Program
{
    public static void Main()
    {
        ma_engine engine;

        ma.engine_init(null, &engine);

        ma_sound sound;

        byte[] utf8 = Encoding.UTF8.GetBytes("test.wav\0");

        fixed (byte* pFile = utf8)
        {
            ma.sound_init_from_file(&engine, (sbyte*)pFile, 0, null, null, &sound);
            ma.sound_start(&sound);

            Console.WriteLine("Playing...");
            Console.ReadKey();

            ma.sound_stop(&sound);
            ma.sound_uninit(&sound);
        }

        ma.engine_uninit(&engine);
    }
}