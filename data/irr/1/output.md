## 1 \- 20:3308:116
ably explode later or explode if you turn on like, you know, LTO, and LLVM has access to cross function information.

**Interviewer**\
Gotcha. Gotcha. So it's more that there, there's a certain category of errors you wouldn't be able to find in Miri, you don't expect that those will be a huge issue in foreign code. So it's not something that you're necessarily like super concerned about. But if you did have a magical bug detector that could find all undefined behavior, you'd be fixing all these 

## 2 \- 35:5200:78
ing. I'm definitely not the first person to think that neither of you. I mean, Redux is an operating system written in Rust for those very reasons, right?

**Interviewer**\
Yeah. So, you mentioned, creating safe abstractions around some of these lower level inline assembly instructions, could you describe what those abstractions would look like and how you would interact with them in that application.

***Participant***\
Yeah, so I mean you can think of the, you can think of these BIOS interacti

## 3 \- 3:504:145
eate bindings and sort of evaluate which approaches you feel are the most effective? 

***Participant***\
Yeah. So I mean, a bit biased because I wrote diplomat because but I also wrote diplomat because of like, I've been writing FFI for ages and have kind of a lot of opinions on this. So I think I mean, I think the thing is, it's hard to some of these tools are unidirectional, some of these tools are unidirectional, the other directional and other direction and some of these tools are bidirecti

## 4 \- 26:3913:419
ce with that. I know like that's used for, for a lot of like JavaScript and webby stuff, but for, for wasm time specifically, that's actually all been manual. It's all been, we wrote the CAPI manually, we wrote the C headers manually, and then we wrote all of the bindings and everything which manually, we don't actually have auto-directed, I think like that. And one of the primary reasons for that was basically just, that's what we saw was reasonable at the time, like the, the, the major thing w

## 5 \- 3:516:1599
n, when a function ABI is defined when they're like calling convention and stuff happens, whether or not a type from the parameters or return values goes in a register or on the stack or be had a pointer or whatever, those different things differ based on the kind of thing it is. So if you've got primitives on either side, they'll work the same. But if you've got a struct on one side and a struct on the other side, it's not just that it had, it's a struct, like it can be a struct, it can have th

## 6 \- 3:516:2362
I've seen more of these problems. And it is well within the scope of what C++ and Rust are allowed to do to differ on this. And to some extent, like C++ and Rust don't have the same constant of destructors in the first place. So when you say a type with a destructor works this way, you can't necessarily mean the same thing on the Rust side in the first place. But also it is very much like C++ has choices on how to do this and Rust has choices on how to do this. And they haven't necessarily picke

## 7 \- 26:3931:3275
 is that given the LLVM attributes involved, what this ended up being was a function that takes ampersand self that writes to ampersand self like to data that thinks that it's owned by ampersand self. So LVM thought that this pointer was read only and noalias, which meant that nothing else was like pointing to it's all pointers. Basically, it was basically a certain LLVM were not going to write through this pointer, but then we wrote to the pointer. So because it was undefined behavior, it just 

## 8 \- 37:5708:84
**Interviewer**\
Gotcha, are there any other like tricks that are similar like that with pointer arithmetic that you have to do in that code base?

***Participant***\
I think the only other like weird pointer arithmetic kind of unsafe stuff I do is really like, I've got like a bit of a compile time reflection system built around these objects. So like, there's a, you know, for the admins of the game, they've got basically a way to peak and poke at objects through the game itself. And so like, yo

## 9 \- 3:435:360
f stuff where it was just like, yeah, to do this refactor I need to change how we use this pointer in C++. Oh, this pointer can be null. That was not clear. Stuff like that. That's a C++ problem itself where I'm making basically a pure C++ change. There's Rust involved, but the actual change I'm making is mostly a C++, can be expressed in C++ and then there's like some nuance there. Then there's the other one, which is thread safety stuff. This is like a tricky middle ground because what we were

## 10 \- 7:905:688
g. And that would obviously be a problem. And at the same time, Rust allows you to use that type as the type of static as long as you put none in there. The moment you use some, it stops allowing that. So it's revealing the value of the static to figure out if you're actually allowed to have that value in the static. If you just do the type based analysis, you'd be, no, no, no, that's bad. But since it's compile time, you can actually look at the value and then make the decision. And that has be

## 11 \- 19:2771:1786
ack to the self-containers. So if I change some unsafe in one part, the other part ideally shouldn't break because it should be robust, a little self-contained. I think that's generally the most important thing, just being self-contained, being well isolated, being well encapsulated. And then if you have a small unsafe module, you can clearly document it and document why it's okay and figure out all the reasoning and everything.

**Interviewer**\
That's interesting because it's like, I could ima

## 12 \- 19:2771:1837
afe in one part, the other part ideally shouldn't break because it should be robust, a little self-contained. I think that's generally the most important thing, just being self-contained, being well isolated, being well encapsulated. And then if you have a small unsafe module, you can clearly document it and document why it's okay and figure out all the reasoning and everything.

**Interviewer**\
That's interesting because it's like, I could imagine having a very, very well encapsulated unsafe m

## 13 \- 7:848:161
of trying to match up various different APIs that don't quite match up.

**Interviewer**\
Gotcha. So in each one of these cases where you use unsafe, the patterns that you're implementing are the same. So that makes it easier for you as someone who's maybe contributing to this project or just examining the documentation or the code base to understand how these operations are safe.

***Participant***\
Yes, how these operations are safe when used together or after each other. Like each operation o

## 14 \- 8:1191:313
d JNA, that it sort of dynamically loads the compiled binary and sort of introspects into the available functions and calls them as if it were a C library from Java. Yeah, kind of don't use it because you'll hit a wall in what you can do. And it's not quite as fast as JNI anyways. JNI in itself is already quite slow. You're talking about an order of magnitude slower is like 20, 25 times slower than calling a native Java function. Gotcha. So yeah, you don't want to make that like 40.

**Interview

## 15 \- 35:5398:118
*Participant***\
You're looking for more, if I had a bug, how would I go around solving it? Is that what you want?

**Interviewer**\
Yeah, no, I mean that, but I'm also kind of curious about, like, what your process is to decide whether or not a crate is something that's good to use or not.

***Participant***\
Because like, so when you're, when you found that particular use case of mem uninitialized. That tells me that somebody either hasn't maintained the code or disabled the warning.

**Interv

## 16 \- 17:2519:770
 ENV or whatever for your workspace, you can get you can have an outline through that, which is pretty convenient. I'm not really a huge fan of Rust’s fetish for like environment variables. But if you're setting environment variables in a config file, it's not really a big deal. You know, because like the cargo, the cargo configure whatever has like a dot ENV section where you can set everything. And I'm like, ah, that's okay. But I'm like, it's not as good as CMake's toolchain file.

**Intervie

## 17 \- 3:540:1325
moving, one thing I'm moving towards is definitely I'm working on with a friend of mine working on this little mini book to teach people about this. And it will contain a bunch of the things the unsafe code guidelines group is up in the air about, not saying that do it this way, but saying it's in the air about it. Also, here's probably the best way you can avoid having problems with this. And we're all understanding that if they do, if they end up breaking it, they will make sure if they end up

## 18 \- 35:5434:165
und my unsafe, run it through Miri or Valgrind or something, right?

**Interviewer**\
Gotcha. So with Miri, I guess you were able to use it for the chess application, but my guess is because it doesn't support non-Rust code very well, were there any parts of the bootloader that you were able to run through Miri?

***Participant***\
No. 

**Interviewer**\
Gotcha. Yeah. So I guess do you have any ...

***Participant***\
Yeah. That's where you go. I think I've probably... I've used Miri before to b

## 19 \- 20:3326:377
t getting at what you want from it now? Or are they all sort of missing a lot of these features that you feel that you don't, that you'd want in terms of more refinement type style reasoning, or just the types of invariance that you'd want over unsafe code?

***Participant***\
Hmm. I think Prusti is kind of the most complete one that I've used. I mean, it still suffers from the problem, kind of the more or less inherent problem of being an add-on to where there's no guarantee that the code you'r

## 20 \- 22:3573:64

So you often see, you know, you often think, oh, it'd be nice to represent that by a VEC, but they're not on the heap. They're in hardware. 

**Interviewer**\
Right.

***Participant***\
And typically we have some of them use virtual addresses, some of them use physical addresses. 

**Interviewer**\
Right.

***Participant***\
So sometimes you need to go back and forth between virtual and grab it, grab the address that you passed in previously. You know, once the hardware says, hey, there's been 

