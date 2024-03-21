# 1 - 26:3859:1374

Like we can still infinite loop. We can still crash your program. Like actually, can we crash your program? I don't think we can. No, no, no, not crash. It's just infinite loop. Infinite loop is the worst one and resource exhaustion. Like we could probably allocate a lot of memory if you don't live it, things like that. But sorry, I don't mean to say that, like, we don't have any preconditions along the lines of like, if you use the safe API, you still have to make sure that you do these other things and things like that. We very much try to give you the guarantee that no one's safe, perfectly. We'll never crash. Only might consume too many resources.

# 2 - 32:4955:11

So you have data that's shared between threads, so you'd need it to live for as long as each of those threads are living, and you might have concurrent access to the, the like, concurrent mutation maybe to the object, but you want that to be synchronized, so you'd wrap something in the object.

# 3 - 26:3937:99

Definitely. So and Miri is a very recent, like this week, last week kind of development. We have not been running for a long time, but we have been running fuzzing for months or years at this point. Fuzzing is our number one tool for finding issues. And that's like we lean on that extremely heavily. If you're looking for a very simple comparison between ASAN and Miri, we can run JIT code in ASAN can't run JIT code in Miri. 

# 4 - 37:5588:578

And the serialization, deserialization previously would just kind of populate that pointer at runtime and so we auto-gend repopulating that pointer when everything is loaded, like did a nice topological sort to actually just not have to explicitly encode the dependencies but allow that to be auto-determined. But so all of these things are used and referenced all over the place in the C code base, right? So the Rust side is allocating them. But then so anytime you want to use them from Rust, like if you want to have serde serialize and deserialize, you need a reference.

# 5 - 28:4136:506

And so you can see stuff like the [name] crate works around this by having just a kind of a shitload of lifetimes on everything. And, like, that's a great crate. And it's a really good approach. But it also is very hard to, like, put those objects, like, use those objects in a way that's not, like, okay, I just have one function that does all the [name] stuff here. And then, like, I throw away all the objects at the end. And then it's hard to keep those objects around for very long unless you want all of your structs to end up with a bunch of lifetimes, which is okay, but is painful for a, you don't want that in a library and a lot of, it'll scare away new programmers for sure.

# 6 - 17:2357:621

So I was like, I could use a RefCell, but it's a lot of ceremony for basic because I was like, you know, the safety RefCell would have added is actually pretty minuscule compared to like, just the sheer complexities of like, am I actually associating the right pointer and the right structures and that getting through in the right way and stuff like that. Yeah. Yeah. So I was like, you know, RefCell does add, Yeah, RefCell does add some extra safety. But when it comes like to the big, broad picture of things, I'm just going to be everything's going to be caught by Valgrind, regardless.

# 7 - 9:1612:360

So, yeah, actually, I haven't figured out a way to make me to like, for example, check the version number before reading and then check the version number again after reading. This kind of bug happens a lot. Actually, it happens. It takes a lot of time because concurrency bug is really difficult to find. And also, the case that Yeah, like, similarly, like, when I check the, when I read the code, okay, I'm just doing the same example, because I'm doing commerce and like, optimistic read, I read the version number and I read the data.

# 8 - 6:712:1200

It's not exactly correct because Rust's, uh, implementation is like too rapidly changing at like the micro level to like formally specify what it is. Uh, but stacked borrows is like a really, really good approximation. And so for most people, if stacked borrows throws up an error, you have a problem. Uh, for me, Miri got on my nerves because, uh, stacked borrows didn't handle relative pointers where you create intervening references properly. Uh, it basically always detects that as undefined behavior. Uh, and that really made me sad because I wanted to use Miri to check everything else, but it would just instantly error out as soon as I, uh, did like one thing with a relative pointer.

# 9 - 6:706:3395

So it's basically not going to cause any problems when it's boiled down to like LLVM IR. Uh, but still it's not exactly in alignment with what we say things should be undefined behavior and having me recheck that all of your objects are like recursively initialized is also really tough. So there's this ongoing discussion of like, should we allow mutable references to be uninitialized as long as you don't read from them first? And, uh, it's just a question, you know, no one knows the answer.

# 10 - 35:5191:94

The unsafe there is this little bit of assembly at the start. Any inline assembly for it to call the BIOS disk functions use interrupts and those are inherently kind of unsafe and to do so you use some inline assembly.

# 11 - 28:4364:523

I mean, a lot of these are fixed now, but like the handling panics, it took so long for me to figure out how to handle like wrap a function and catch a panic and then not have a case where that function could panic with a payload that itself when it was dropped panics again. Which is a really ridiculous case to worry about because who is trying to like really hard to hone their own program, but... Yeah, I'm not sure I have a satisfying answer for this. 

# 12 - 14:2082:212

Yeah. Or lock up or something like that so it was very good. I'm not happy with writing unsafe code. You know, I try and I try to keep it at a minimum but it just like, you know, certain things tend to be unavoidable. I guess we covered all the unsafe in this one. Yeah. Okay, why is this there's some I didn't write this. So this would kind of be typical of the unsafe code that you'd see in embedded. Let me just show you other code, which in general, it's cases where you're interfacing with the hardware on a level where I mean, once you start writing magic. The hardware abstraction layer should be, you know, in some cases the hardware abstraction layer is unfinished. And so I just go around it. In other cases, even if it is in the and you can use your hardware abstraction layer it is kind of unsafe what you're doing so putting it in an unsafe block I think is entirely appropriate.

# 13 - 3:477:81

Yes. Yeah. And the tool does not read the C API. This tool also generates the C API.So like we are not the thing that we as humans write is not C API. The thing is we as humans write is something that looks like the Rust API just that it's somewhat restricted in what you can do. You can't do arbitrary things in it. It will like if you start doing generics, it will yell at you. If you start doing start using really complicated types, it will yell at you. But it can do most basic things. And as long as you stick to that subset of Rust, it will generate a C API for you and the tool.

# 14 - 17:2351:282

Because I was like, you know, I've been doing C++ for so long that I'm like, can I handle actually you know, keeping a mutable reference in scope and not letting it escape. And I was like, yeah, I can do that. Plus I did, I did do some prototype testing on the Rust playground. I just like copy pasted one little function. I was like, okay, I have like an Rc UnsafeCell. Let's see if, you know, a rough gist of what my code is doing is valid in Miri in the past. So I was like, all right, we're going to spam the server without the code base then.

# 15 - 17:2432:29

Yeah, I think the ability to represent uninitialized storage via the type system and how they have it work so well is what just makes it so beautifully brilliant. Yeah, because that's the thing. I think maybe you could try to hack something in similar to C++, like in maybe something similar to C++, but it would be a strict downgrade compared to Rust.

# 16 - 17:2525:917

But I'm like, I kind of miss the days of manually controlling, I'm gonna have a static archive here and another one there and I'm gonna  them for just as executable. Like I really miss that kind of control CMake gives you. Whereas cargo is a lot more declarative, you know, it's like that. It's the convention over configuration school of thought, because I know rails is very similar where it's like, you put your files in this folder and they're automatically part of the whatever. And I kind of hate that.

# 17 - 28:4256:590

Yeah. It's tricky to use right, though, because you often want to be able to have a function that takes it MaybeUninit, like a mut MaybeUninit, and then initializes it. And you want to be able to like, okay, I actually have an initialized slice and I want to pass that into that function or something. And you can't do that because you can't really trust the function you're passing it into, unless you know the source of it. But you can't trust it not to just write maybe uninit into your previously initialized bytes, which now would be unsafe. That's more of a, that's like why we couldn't replace like the read APIs with a maybe like mute maybe on the slices.

# 18 - 37:5690:796

Actually, I cheat a little bit in the allocation. I allocate the space for the arc just in front of the object itself so that I don't have to do any sort of lookup. Like I take the pointer, I allocate arc and then allocate those things next to each other in memory. And so like the pointer that we get from C is always the start of the C object itself, but actually it's the interior of a struct that has the Rc/Arc in front. So I can just subtract off the pointer and grab the arc once I've made sure that the pointer is valid kind of thing.

# 19 - 7:920:54

***Interviewer***\
Gotcha. So in the case of static mut, it would be allowing that. But if you make it constant, then use interior mutability, then it avoids that problem.

***Participant***\
Exactly. Because then you can run around with an immutable reference to that RefCell<T> wrapper and only access it mutably when you actually need to. So you never have two mutable references to the same memory location.

# 20 - 22:3549:53

But then you need to make sure that it's sort of like any FFI interface. In the FFI, you have to make sure that thing actually lasts for however long the hardware is using that pointer. So typically we'll Box it up, put it in a struct that is tied to some other struct that represents a capability to access that piece of hardware to ensure that it lasts long enough.