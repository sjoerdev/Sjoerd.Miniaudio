using System;
using System.Diagnostics.CodeAnalysis;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace Sjoerd.Miniaudio
{
    public partial struct ma_stack
    {
        [NativeTypeName("size_t")]
        public nuint offset;

        [NativeTypeName("size_t")]
        public nuint sizeInBytes;

        [NativeTypeName("unsigned char[1]")]
        public __data_e__FixedBuffer _data;

        public partial struct __data_e__FixedBuffer
        {
            public byte e0;

            [UnscopedRef]
            public ref byte this[int index]
            {
                get
                {
                    return ref Unsafe.Add(ref e0, index);
                }
            }

            [UnscopedRef]
            public Span<byte> AsSpan(int length) => MemoryMarshal.CreateSpan(ref e0, length);
        }
    }
}
