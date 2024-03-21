# 1 - 6:706:2861

And so, uh, there are things that are okay by convention, but might technically allow for undefined behavior. Um, and so like the unsafe code guidelines have like slowly been like tweaking this way and that way to make sure that they like tighten in on what is okay or not okay in Rust. Uh, if you make a mutable reference from a, uh, an uninitialized value, like if I have a MaybeUninit and I have a pointer to it and dereference it into a reference, uh, is that undefined behavior? The gut reaction is yes, but there's a lot of question about, hey, what if I want to pass in…

# 2 - 22:3366:31

Okay. Well, I first heard about Rust in a conference back in 2017, and at the time I was also in academia. We were investigating some issues with state management and operating systems and just general operating systems principles. Once I learned about Rust, the ownership system and kind of like the whole affine type system based safety and the model surrounding that attracted us for a variety of research purposes. So I think that's why we started using it. As we used it more, we used it to create a new OS from scratch.

# 3 - 10:1898:354

Yeah. And I remember, so the particular user was having issues with their code. Like, why can't I do this in Rust? And I think they ended up like trying to do type punning with when like a, one of the fields was a pointer itself, like a reference to a string or something like that. So, and you can imagine, I've just got a bunch of bytes, and then I've, I've cast it to a pointer to whatever. And if those bytes came from a file, sure, my struct will contain a field, you know, which contains a pointer, but that pointer points to garbage now, because, you know, it was written by a different process. 

# 4 - 14:1989:477

No worries. I was reading this book here. The concurrency models in seven weeks. And that kind of got me thinking about it. I was trying out Go and figured out that didn't really answer my questions. And then I started looking into Rust, maybe more of a coincidence. I guess the trigger was I saw it was always the most loved language in the survey. I thought I'm going to find out at least what this is about. And in time it did actually provide a lot of answers to the problems that have been struggling with for years where concurrency and multithreading have been involved.

# 5 - 10:1766:60

It's, you end up have, when you, it depends on the language, like some languages have like PyO3, which gives you nicer ways to do things, like, you know, wraps a lot of the unsafe, but you have like other languages where you have to write like going from Rust to the C API, and then from the other language down to the calling into the C API. So you have to, so it kind of sounds like it's unidirectional, but you have to do both sides of the bindings.

# 6 - 14:2251:263

I haven't, I haven't had. I haven't had any, any, uh, shows a lurking bugs. Uh, you know, what you typically have and see, but it looks good. Compiles, runs. Yeah. And if there are problems, you can just spot them immediately. That's my, just my experience. I think maybe once I had a problem where, uh, there was some alignment issue, but that was tied to this. And that was tied to the, the AVX code.

# 7 - 17:2534:147

But yeah, so Miri's been really great for that. Especially because it was like a vector, you're doing so much weird stuff to it because the iterators, like when you start draining and leaving holes in it. That's part of the problem why it gets so complicated. Because if you like the drain iterator removes a sub slice from the vector. So that's when it gets tricky, because it's like, you know, you have to like set the length of the vector, you have to like truncate the vector essentially, leave the elements behind in the trail. And yeah, so there Miri's pretty clutch, as you know, I'm not doing any ffi.

# 8 - 20:3207:2

***Interviewer***\
Gotcha. Gotcha. Well, so extending on this, what's an example of a bug or just something unsound that you discovered in unsafe code?

***Participant***\
I mean, a good amount of them. I mean, a lot of them of my own creation. But let's see. I mean, the aforementioned like thin string reallocation invalidation stuff. Couple data races. Some little like fun memory ordering bugs with atomics.

# 9 - 8:1071:392

So the stink comes primarily from that style, yes. But when the language is so big, you find out that style matters because it changes your ability to review code. And yeah, I mean, in extreme cases you have fully deprecated features, but like auto pointers and things like that, which I think by now are long gone in most code bases. But yeah, when I started coding C++, it looked very, very different.

# 10 - 2:272:100

***Participant***\
Basically, I was using an existing library, but it didn't have some of the functions that I needed.

***Interviewer***\
Mmm hmm. I don't remember if I forked the library, sent a PR or something else, but for most things, I use the existing library.

***Interviewer***\
So these are bindings that you just wrote by hand then, without using any tools to assist you?

***Participant***\
Yeah

# 11 - 26:3931:1491

And so we had a little lib call, which like it went through and jitland. It gets a VM context. So what it would do is it, given a VM context pointer, I'm going to rewind it, get the instance pointer, the instance pointer, the instance pointer, then I'm going to like take the parameters to the instant, the table, grow a function call, go do some runtime stuff, grow a vector, all that good business.

# 12 - 32:5007:241

***Interviewer***\
Gotcha And is it that like, are the results once you've finished compiling correct? Like have you had any issues with like mismatched types maybe, or like the interfaces that it generates being incorrect in some way, or are the results that you get generally correct after you finish doing the compilation and configuration?

***Participant***\
I think once I'm done compiling everything, and when there are, maybe I would fix them or maybe the bug or whatever errors you have here, I think once you're done, that's it.

# 13 - 17:2405:17

So in some ways, the undefined nature of Rust really, as a library author, it makes you very confused. Like, what should I do? Like, what if I am handling up, you know, what if I am handling up and unwinded my drop? And I panic again, you really don't know what's going to happen. Yeah. Yeah. So it's both difficult because you're inherently reasoning reasoning about like a complex memory safety scenario. But you have sort of these two other factors, which is there are safe operations that can invalidate what you're currently iterating on or just operating on.

# 14 - 22:3387:1838

So you typically store it within the actual memory that has been allocated for a particular purpose, right? You allocate, you know, let's say you allocate eight kilobytes, right? So some tiny part of that eight kilobytes is used for the metadata, right? There is apparently no way to represent this in, say, Rust, right? This is in effect a self-referential data structure, right? So that's, as you probably know, that's a very hot topic in Rust and how to represent them safely is kind of an ongoing issue.

# 15 - 8:1323:310

So I'm basically I'm basically completely breaking Rust's expectation because my my C object holds this Rust object a mutable it basically holds a field and then I just want to update it in place as if it were a moot self. But what I'm doing is basically taking it updating it and then putting it back in putting it back in practice so you have this pointer right back into the same location.

# 16 - 7:1043:282

I mean, one thing has already happened. I always wanted Miri to be able to execute functions without knowing the arguments. Basically symbolic execution and then running a sat solver to find out if there's any problems in that function. And turns out people have developed that. There there's multiple tools in the Rust community in the data analysis community here that have demonstrated that they can do that for certain simple functions, simple being a very stretchable term. So some of these are actually getting very complex and they detect unsoundness without ever actually executing the program.

# 17 - 20:3125:14

So yeah, I mean, I'm somewhat of the opinion that the rust compiler is correct in that, because I mean, C does not really provide very many guarantees about a lot of things. And so, you know, from the perspective of the rust compiler who's trying to do, who isn't just trying to do like in practice, like in practice correctness kind of, like it's trying to do a total correctness check for everything. And so in terms of total correctness, no, you can't pass a 20 or 128 bit integer across the boundary because, you know, C doesn't support that. You know, some C compilers do, but C does not support that, you know, as a standard, which, you know, is very much the fault of C. But yeah, yeah, yeah.

# 18 - 3:552:214

I think like, basically, a lot of progress here is just blocked on the unsafe code guidelines finishing. And typically, the unsafe code guidelines are the official rust rules around what is and is not defined behavior. Whereas what I'm working on is not that I talked to those people all the time, what I'm working on is kind of like a book that is not a set of rules, but rather teaching you unsafe. And teaching you like how to best practices for read and good unsafe.

# 19 - 17:2312:410

Yeah. So one of the things that's really different and the problem is there's so one of the biggest problems I think with unsafe Rust is there's no actual specification of like an object model. So like right now, if you're writing unsafe Rust and you want to. So one of the big things with C++ is you have the decoupling of object storage from object lifetime. So, you know, C++ goes through a lot of wording, like very careful wording to be like, you know, we have the notion of storage and installation and then there's objects whose lifetime live within that storage. And so that's when you have things like placement new and then, you know, in place destructors. And so with Rust, there really is none of that.

# 20 - 39:6087:21

I think with Rust programming languages, it comes to using, you know, the various types of binding tools. I think it's a, an awesome, awesome experience and I can't complain. But it got to you. So they, they might be, you know, some kind of challenges in there. But it's been a nice experience, I would say. Yeah. This place.