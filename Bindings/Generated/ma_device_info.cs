using System.Runtime.CompilerServices;

namespace Sjoerd.Miniaudio
{
    public partial struct ma_device_info
    {
        public ma_device_id id;

        [NativeTypeName("char[256]")]
        public _name_e__FixedBuffer name;

        [NativeTypeName("ma_bool32")]
        public uint isDefault;

        [NativeTypeName("ma_uint32")]
        public uint nativeDataFormatCount;

        [NativeTypeName("struct (anonymous struct at C:/Users/sdev/Documents/GitHub/Sjoerd.Miniaudio/Generator/miniaudio/extras/miniaudio_split/miniaudio.h:3366:5)[64]")]
        public _nativeDataFormats_e__FixedBuffer nativeDataFormats;

        public partial struct _nativeDataFormats_e__Struct
        {
            public ma_format format;

            [NativeTypeName("ma_uint32")]
            public uint channels;

            [NativeTypeName("ma_uint32")]
            public uint sampleRate;

            [NativeTypeName("ma_uint32")]
            public uint flags;
        }

        [InlineArray(256)]
        public partial struct _name_e__FixedBuffer
        {
            public sbyte e0;
        }

        [InlineArray(64)]
        public partial struct _nativeDataFormats_e__FixedBuffer
        {
            public _nativeDataFormats_e__Struct e0;
        }
    }
}
