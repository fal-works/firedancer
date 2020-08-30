# Firedancer

A Haxe based language for defining 2D shmup bullet-hell patterns. 

You can write any bullet pattern in Haxe and compile it into bytecode,  
which can be run on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

Inspired by [BulletML](http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html).


## Usage

1. Install [Haxe 4](https://haxe.org/).
1. Install Firedancer (command: `haxelib install firedancer`)
1. Using the API of Firedancer (see [Wiki](https://github.com/fal-works/firedancer/wiki)), define your own bullet patterns and compile them into a `ProgramPackage`.
1. Attach any program(s) to your actor(s) and run them on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

*Note: Firedancer is not a game engine. You have to create your own program to update/render your actors.*


## Documentation

[Firedancer Wiki](https://github.com/fal-works/firedancer/wiki)


## Caveats

- It's still alpha and quite unstable.
- A bunch of spaghetti code!!


## Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.4.0 or compatible
- [sneaker](https://github.com/fal-works/sneaker) v0.10.0 or compatible
- [ripper](https://github.com/fal-works/ripper) v0.4.0 or compatible
- [banker](https://github.com/fal-works/banker) v0.7.0 or compatible
- [reckoner](https://github.com/fal-works/banker) v0.2.0 or compatible
- [firedancer-vm](https://github.com/fal-works/firedancer-vm) v0.1.0 or compatible
