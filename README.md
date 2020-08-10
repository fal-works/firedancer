# firedancer

(WIP)

Define, compile and run 2D shmup bullet-hell patterns. 

You can write any bullet pattern in Haxe and compile it into bytecode,  
which can be run on `firedancer` virtual machine.

Inspired by [BulletML](http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html).


## Compilation flags

|flag|description|
|---|---|
|firedancer_verbose|Emits verbose log.|
|firedancer_positionref_type|Specifies the underlying type of `firedancer.types.PositionRef`. Example: `-D firedancer_positionref_type=broker_BatchSprite` (Valid values: "broker_BatchSprite" for `broker.draw.BatchSprite`, "heaps_BatchElement" for `h2d.SpriteBatch.BatchElement`, otherwise an anonymous structure `{ x: Float, y: Float }`)|


## Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.4.0 or compatible
- [sneaker](https://github.com/fal-works/sneaker) v0.10.0 or compatible
- [ripper](https://github.com/fal-works/ripper) v0.4.0 or compatible
- [banker](https://github.com/fal-works/banker) v0.7.0 or compatible
- [reckoner](https://github.com/fal-works/banker) v0.2.0 or compatible

See also:
[FAL Haxe libraries](https://github.com/fal-works/fal-haxe-libraries)
