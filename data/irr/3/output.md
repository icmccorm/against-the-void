# 1 - 3:519:241
Yeah, a memory. Honestly, one thing that I remember, the C and C++ model of memory is not that different. It's just that you have to keep track of it in your head. And I remember when we were doing the [browser] stuff, we had a bunch of experienced C++ programmers start to learn Rust when we were doing this. And I was helping them do that and kind of also very interested to know where their challenges were. And the thing that I remembered was they did not have problems with what was widely known as the most complicated part of Rust. They were like, yeah, the borrow, that's fine. And their reasoning was this is how we think anyway.

# 2 - 19:2687:189

***Interviewer***\
Gotcha. Okay. Gotcha. Nice. So, just sort of any particular... Is there a... I guess, how do you decide a particular area to contribute to? Is it focusing on just an arbitrary issue that you see reported?

***Participant***\
I just sometimes have random ideas and try them out. Sometimes I see issues and fix them, or just have an idea that comes to my mind or an idea that I see some and I get inspired from somewhere, and then I just work on it, and then something may come out of it sometimes.

***Interviewer***\
Gotcha.

***Participant***\
There's no real concept. I'm just like, I do whatever the fuck I want.

# 3 - 31:4613:64
I'll tell you the other thing about the unsafe Rust code is that it's definitely was not quote unquote, ergonomic, like I'm doing, grabbing a pointer and then doing an offset on it, you know, and like, you know, I could probably, I could probably just look at one of these things and I have C lib, I have clibimpl.rs. Okay. In fact, what I did is I had my clibimpl.rs built, my application also builds to native code too. And I build the C library implementation. But then because I don't have to go and link, you know, do these shenanigans outside of Web Assembler, I wanted, I wanted that code to be built and be unit tested alongside my native code. And then I just had some like wrappers that basically activate the entry points only when, only when I'm compiling on Web Assembler. Okay. Yeah, it's like, like here is an implementation of, of the realloc function in C plus plus.

# 4 - 10:1802:269

And also, all of this adds to build times. So you, you really want it in your build script, but it's, it's a really painful, like a heavy dependency and it, yeah, and it's, it can be painful to, to use to manage versions. I can't remember what the cross compilation story is like, but knowing, like, native libraries, it's probably, actually no, it wouldn't matter. Yeah. I don't know. Cross compilation can sometimes be a pain, especially when native libraries are involved.

# 5 - 3:522:1768

That's Rust in Rust, you kind of just have, you do have a distinction between l values and r values are what we call places and temporaries. But that distinction is basically internal. And you need to care about it in a couple places when it comes to borrowing. But the fixes are straightforward. So it's not it's not as in your face as it is in C++, where I've often had to think about these things. So that's like one difference. But overall, like the memory stuff is still similar, the way you deal with memory in Rust is very much inspired by the way people manually do it in C++.

# 6 - 37:5612:1111

I think the game is probably where I've used it the most. I've got like one microcontroller that has some unsafe Rust in it. And I think maybe, I think there's maybe one pattern that I commonly use unsafe for or previously did before one cell was stabilized. Now that one cell is stabilized, I feel less inclined to use that pattern all over the place.

# 7 - 9:1642:714

And memory sanitizer, oh, I forgot. I actually use address sanitizer more. And the memory sanitizer is mostly about, I think I'm leaking, memory leak. Yeah. Because those sanitizers are incorporated into the fuzzer. So when I run the fuzzing, like libfuzzer, it will like enable the sanitizer by default. Yeah, I also use Miri before, but Miri is more limited because I have to deal with a lot of IO operations and a lot of functions that are not supported by Miri. At least the time I'm using it. And it's pretty useful. So it's both the speed and the fact that Miri is not, like it just doesn't support the types of functions that you need.

# 8 - 32:4998:328

Yeah. Yeah. Yeah. Of course. I think, you know, computation is a common problem. Sometimes it takes longer time to compile, and especially with a larger code basis, or maybe projects with many dependencies, the process is, is too slow. And I feel like it's too slow, like you need some work to be done.

# 9 - 17:2333:476

Oh, yeah, sure. It's just, it's because how you want to have to derive raw pointers from the UnsafeCell. And I guess how it was, I think how Rust does interior immutability is really interesting. I know there's like some pithy C plus plus to have who's kind of like, Oh, it's the same thing as mutable data members. But I think the fact that because of how, you know, I don't think a lot of C plus plus devs in particular understand that rust doesn't have type based aliasing analysis and only has the ability based. And so I think it's very tricky when you're sort of like using the unsafe cell, converting it to its underlying raw pointers and or deriving the mutable pointer from it. When it when it's really permissible to just go ahead and turn it into a hard mutable reference.

# 10 - 20:3264:131

Yeah, I mean, Miri is incredibly helpful, you know, like it's a great diagnostic tool. Usually for a lot of them, I end up or I guess more of the the checkers, you know, like all the sanitizers, Miri, that sort of thing. I usually run those as part of CI or usually part of my or for some things part of my test suite, if it's, you know, like it specific enough. But I'm a Clippy advocate. I'm a Rust FMT advocate. I use them extensively. I think they're fantastic tools.

# 11 - 35:5443:1405

However, Rust knows at compile time, because you've told it it has to be, Rust knows that it has a certain minimum and maximum. So then you can use the extra space for niches or that kind of thing and it avoids bounds checks. One of the bugs I had with this was an off-by-one thing. My maximum or minimum was off-by-one because I didn't understand how this Rust internal attribute worked, whether it was off-by-one. It's a classic one.

# 12 - 17:2393:224

Like they found out that you could easily create leaks. And so they made forget and drop safe functions. So you have to be prepared for a user just randomly dropping and randomly forgetting whatever you hand them. That could be a giant pain in the ass. 

# 13 - 3:486:702

So yeah, so for unsafe code, unsafe library code, pre and post conditions work quite often quite quite well, sometimes, not for everything that they work often. But for unsafe, FFI code, they really don't because to do this kind of thing, you've got to maintain a bunch of state that you're not going to be maintaining on the other side.

# 14 - 19:2753:1193

And at least some of the unsafe data structures, they pass MIRI, that's something they didn't use to at some point, but I fixed some of them and then one of the structures was changed and yeah, but it's also not tested in CI. So if someone's if structure did regress and also some like the self-contained structure data structures, they pass MIRI, some of the more involved unsafe code, those cannot be tested inside MIRI because MIRI cannot reasonably run the entire Rust compiler because it's very slow.

# 15 - 2:17:456

And in general, what I said before for Rust applies. Specifically for the Embedded project, it's not the first time I write a small Embedded project, but it's the first time I write something that's actually usable.

# 16 - 14:2076:165

Yeah, so here is a problem with the ownership. I don't know this is in the Arctic framework, but there's an older version may hope maybe. I'm not sure who took them and tried to just steal them instead. Yeah, this is really low level stuff where you're actually writing into the re allocating a vector table for the CPU. What's going on here. I'm not enabling a DMA for some reason. Reboot magic. So this microcontroller, it will, it doesn't erase the RAM during reboot. So then I have certain sequences that okay, say you want to update you want to flash other firmware or you want to go into sleep mode. And this handle is just write a magic value to RAM. And then when I boot up by check, okay, what is this this magic value. So I just use this maybe on in it. I guess you need unsafe to access that. Yeah.

# 17 - 7:890:33

That goes back to the embedded world. When we started using interrupts, we needed to synchronize our accesses to shared memory between the interrupts and the main program. And for that, we needed to implement our own mutexes because there's no operating system or anything interesting there that you could reuse. And for implementing those, we needed unsafe cell to be able to have interior mutability and then figure out some locking scheme around that to soundly access that shared memory.

# 18 - 7:1019:96

It's more just everything that Miri detects it will detect the moment you start running it. No, there's certain patterns. One thing we've seen is that using synchronization primitives wrongly or using multiple mutable references to the same data keeps happening and is not unsound in practice.

# 19 - 3:435:218

Then there's the other one, which is thread safety stuff. This is like a tricky middle ground because what we were doing, I was working on the Stylo project, we were just taking a parallel style engine written in Rust and bolting it onto Firefox. There are two things tricky about that. One is browsers are very monolithic. The servo browser tried to be less monolithic, but they're still rather monolithic and there are no clean components. You can't just go, oh yeah, that's the style system.

# 20 - 3:435:218

***Participant***\
Yes. You have to write documentation. You have to write a documentation for it.

***Interviewer***\
So what's an example of something that you would document for one of those functions?

***Participant***\
Maybe let's say I call this supposed to perform a low level operation and in this instance, it's also supposed to run some kind of unsafe safety guarantees. So you have to write a documentation to instructs in some kind of file that the code can be handled and I think that's the right way to do it just avoid backlogs and maybe pointer dereferencing or some kind of, yeah.

