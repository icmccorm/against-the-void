## 1 \- 7:884:181
back to the subtyping of the data has addressed us.

**Interviewer**\
Gotcha. Okay. So you mentioned using Box on safe cell, cell and Refcell in unsafe contexts. We already talked a bit about Box. So could you describe some of the situations in which you've needed to use types like unsafe cell or any of the things derived from it and the different challenges that you faced and using that correctly?

***Participant***\
That goes back to the embedded world. When we started using interrupts, we nee

## 2 \- 37:5624:234
*Participant***\
No, I think it's a lot more of the former. You know, I think like, so the longer term goal of this project is really to be able to start writing some more of the game logic in Rust and to actually kind of natively use some Rust data structures instead of kind of like, you know, we talked about the hash map. That's kind of hacked on as like a, we keep a global hash map and expose some like accessor functions to the C world, but like actually storing everything in a hash map might

## 3 \- 6:592:1141
 use like, uh, drop handlers, but they're kind of nasty. Uh, so panic safety is like a particularly thorny, uh, API surface. And then besides that, it's basically just it's raw pointers everywhere. Uh, it's not a really sophisticated API surface. It doesn't expose a lot of types. It's kind of kept as minimal and straightforward as possible. Uh, I could build up more API surface to make it like easier to handle all of those different components, but, uh, I guess this is also a good example. Uh, b

## 4 \- 22:3369:267
rst heard about Rust in a conference back in 2017, and at the time I was also in academia. We were investigating some issues with state management and operating systems and just general operating systems principles. Once I learned about Rust, the ownership system and kind of like the whole affine type system based safety and the model surrounding that attracted us for a variety of research purposes. So I think that's why we started using it. As we used it more, we used it to create a new OS from

## 5 \- 19:2834:28
that's going to cause double free, which is rather bad. So then you first wrap it in a manually drop, then copy it over. And in the end, nothing bad will happen. That's like the way I choose ManuallyDrop.

**Interviewer**\
Okay, gotcha. And MaybeUninit? 

***Participant***\
MaybeUninit is just, for example, if you have an array that may be uninitialized for performance, if you have like a one kilobyte array on the stack, like in practice, it probably won't be too bad if I just initialize it and 

## 6 \- 19:2921:485
i today comes from the constant evaluation interpreter, not necessarily from the stack borrows checking. It used to be that the stack borrows checking was extremely slow, but someone optimized that a lot with a little caching and now it's pretty fast. Yeah, most of the slowness comes from the interpreter, although part of the interpreter is also detecting UB. So I think it does like on each move, it checks whether the type is valid and that's just going to be expensive because you have to check 

## 7 \- 7:818:108
in there. But in the end, that only made a bunch of very menial work simple. It did not help us with writing drivers at all.

**Interviewer**\
Gotcha. So could you describe a bit more about the second use of unsafe that you mentioned in implementing a multi-threaded application? Or no, multi-threaded primitives.

***Participant***\
Basically, we have a problem in the Rust compiler where locking is not the right kind of work that we need to protect our data that is accessed from multiple threads.

## 8 \- 6:715:131
nd now I can run everything through tree borrows and it all passes. It makes me very pleased. Gotcha.

**Interviewer**\
Gotcha. Yeah. Interesting. I was also following tree borrows. So that's, that's interesting to hear that that solved your particular problem.

***Participant***\
Yeah. Uh, I was talking to, uh, [name] at [event] last year and I was basically like, please, can I have some sort of fix for Miri? And he was like, I don't know, maybe. So I'm glad that it happened.

**Interview

## 9 \- 35:5233:209
ssembly instructions?

***Participant***\
Yeah, I mean, you can, if you can tell the compiler that it can't make certain assumptions then you're all good, right, but certainly you wouldn't want to violate the mutable aliasing properties, you can't, if, like, straight up when you have two mutable pointers that's undefined behavior, right, so even if some BIOS function lets you get around that that would be bad. I certainly wouldn't, I didn't run into any cases where I had to try and skirt around 

## 10 \- 14:2263:281
 don't know. Once a clippy really helps you find bugs. Uh, I don't know why that, why I checked that it helps clean up your code. Uh, as, uh, what I find it most, uh, what I really like about clippy, now I'm trying to catch up on, on new features and, uh, they come with a different compiler releases, but I guess that don't have the capacity to do a deep dive in every release, but clippy kind of helps me to catch up with it. Sometimes, you know, there's a new feature out there and they'll make su

## 11 \- 9:1429:439
at your, your node can be like one of those two types. But in order to do that, you would have to use a 16 byte pointer, which would give you performance overhead that you can't accommodate for that use case. So instead, you use unsafe and you read the first byte to tell the type and then use transmute to figure out the rest.

***Participant***\
Perfect.

**Interviewer**\
Gotcha. Okay.

***Participant***\
That's the first kind. I think the second kind is I have to use UnsafeCell. So I use Unsafe

## 12 \- 22:3383:1
erfaces, but at some point, right, like in the house somewhere, you need to descend into the low level raw primitive access, you know, like writing bytes to a particular region of some MMIO register. It's just, it's unavoidable to a certain extent.

**Interviewer**\
Gotcha. So, would you say that the use of your, like of unsafe in this project is generally by necessity in these cases where you're accessing lower level hardware and then you're relying on, relying on safe abstractions wherever you

## 13 \- 3:504:1701
for look for this type and other crates and stuff, it's not from here. And that when it works, it works. But when it doesn't work, it's a mess. Because cbindgen does not understand all of Rust, and it can't generate FFI for all of Rust anyway. So my general opinion is that if you're building a tool where your source of truth is Rust code, make the source of truth be very explicitly tagged Rust code, like a separate crate, or separate modules, and both CXX and diplomat do this. And that's part of

## 14 \- 8:1359:222
p on them.

**Interviewer**\
Gotcha, and then speaking of standard testing methods, do you feel that your current development tools handle all the problems you face when writing unsafe or are there areas where you feel that your current tools could be improved or a new tool would be helpful for you so like I'm thinking like the example you gave earlier of of something that can automatically reconcile the differences between the foreign bindings that you're creating and what you actually need the

## 15 \- 17:2411:733
ike, I'm like, okay, it's easier to write memory safe code. But to call Rust memory safe is just like flagrantly, I think it's dangerous. I think it sets a bad precedent for the culture because I remember very distinctly once I was in [platform]. And I was asking, you know, I was still like, I'm still really learning Rust. I've only been doing it for maybe like a year or two. And so I was asking some fellow [users], I was like, you know, do you run your production tests through Valgrind?

***Par

## 16 \- 14:2085:131
is kind of unsafe what you're doing so putting it in an unsafe block I think is entirely appropriate.

**Interviewer**\
Gotcha. Gotcha. Yeah. Just looking at. I just wanted to pull up your screening survey responses for a second to double check something.

***Participant***\
There's another code. I guess when you described the hardware being unfinished. Yeah, the abstraction layer is being unfinished.

**Interviewer**\
Could you talk a bit more about your relationship with that abstraction layer

## 17 \- 31:4398:166
 to start stuff off and

**Interviewer**\
That's perfectly fine.

***Participant***\
Okay. So anyway, what happened was the only supported, the only supported target for for Rusty WebAssembly is wasm32-unknown-unknown. It's essentially raw WebAssembly, no standard libraries, nothing like that.

***Participant***\
I tried to get things like Wasi and the Emscripten targets to work and, you know, I actually like found a few bug reports against the WESem, things like wasm-bindgen and got a big, you 

## 18 \- 14:2037:284
 put a lot of faith in the promises of fearless concurrency. Of course, it wasn't just blind faith because I did have some, I mean, that was the premise of doing this in Rust to begin with was that Rust would allow me to make a multi-threaded implementation with confidence.

**Interviewer**\
Gotcha. Yeah, that makes sense. So then I guess along those lines, another more broad question is, what do you use unsafe for us for?

***Participant***\
That's a good question. So this seismic thing did wor

## 19 \- 20:3063:381
n arbitrary C function doesn't capture your pointer. I mean, generally speaking, most bindings or, you know, functions will be relatively sane with that sort of thing, but yeah, there's, I mean, there's no really way to guarantee that unless you're doing some really deep, like, I don't know, you can probably verify it with a live or something.

**Interviewer**\
Gotcha.

***Participant***\
So then yeah, that would be very difficult to audit, I think, or it's not audit, but to like machine prove.


## 20 \- 22:3531:1073
he contents of that pointer. That one is not particularly complicated, assuming everything goes right. But there were some other cases where some of my collaborators were misusing Box from raw for a pointer that did not originally come from a Box. It sort of worked, but I feel like it would have had major problems had we done anything complicated with it. So misuse of the from raw thing in an unsound manner, because it's very easy to mistake that mistake a Box for a generic pointer rather than s

## 21 \- 31:4688:793
or, and then, and then pass that buffer to something that fills it in. And then there's an unsafe function to go and, and, and, and fill that and, you know, set the vector of the appropriate size. And I think, and I will say I found the blog entries about why you have to do that and not memory on the to be pretty interesting because it went into pretty, into pretty in-depth details about the assumptions that, the assumptions that you're allowed to make and the ones that you're not allowed to mak

## 22 \- 9:1402:311
checker. So for the Rust, you have to manage the lifetime, but in C++, you don't have that thing explicitly enforced by the compiler, but you still have to consider the lifetime, because those things are the critical to make sure that your programming, your memory is correct, but that is kind of optional in C++, and you have to do it after you have refunded bugs, but for the Rust, you have to consider that when you're writing the code, otherwise it won't compile. So that will basically eliminate

## 23 \- 32:5004:175
icky or maybe trouble to you. 

**Interviewer**\
Gotcha

***Participant***\
So it's, it's like the, the main issue is that it takes a long time to compile these. And then also you end up getting a lot of compile, like errors that you then have to go and, and fix manually. So it's, it's not like, it seems to require a lot of configuration. Yeah, that's it.

**Interviewer**\
Gotcha And is it that like, are the results once you've finished compiling correct? Like have you had any issues with like m

## 24 \- 8:1077:1233
ng to be movable by default. So there's still cases that you sort of know better and you go, okay, well, okay, how do I break out of the constraints imposed by the language? And the initial beginner response to that is just to breach out for unsafe, which is not wrong as a learning experience, I think, because it allows you to find where the edges of the language are. Once you start writing more production code, you realize that actually there's cell and ref cell, and there's pin, and there's al

## 25 \- 26:3853:374
. And I see official in the sense of like, there's lots of little cretes underneath that, but they're not like, we don't intend free to use them. It's just kind of how we organize our code. So the official embedding API has no unsafe code in it or rather you can use it without unsafe code. So you can call asm, you can instantiate wasm, you can compile wasm, nothing unsafe there at the top level. So that's been our guarantee the entire time is like, when you talk to it and when we give it to you,

## 26 \- 10:1850:278
 makes sense, and that way you can like straight away I can see and I know that like I'm comfortable with doing that thing. Those like playing around with that sort of unsafe. I know that my coworkers are I can trust them. So I would prefer for them to just to not have the training wheels on and to do things to just be aware.

**Interviewer**\
Yeah, that's right. Yeah, make sense. Yeah, no, that totally makes sense. Yeah. So then let me back up. There was one area of unsafe we didn't chat about 

## 27 \- 10:1874:955
anted to get a particular new feature in. And I wanted to write it in Rust, because Rust was a lot nicer to use than Delphi. So I created a Rust library, which did this thing. It was for to do with pathfinding and nesting. So the idea is that, say, I've got a gigantic rectangle, which is my block of foam. How can I place my, like, say, I'm cutting up pillows. How do I place the pillows to optimally use the material? And I'd written a library for that in Rust. And Delphi was calling the Rust code

## 28 \- 10:1946:566
what I'm doing. And then they proceed to do something stupid. Or you almost in reaction to that and to rust like desire for safe interfaces is that people are like, they try and shy away from it. And like they, any, any code that uses unsafe is like, like heavily, like unnecessarily, like criticized. So it's like this code, or yeah, I don't know how to, it's like it's unsafe can be demonized in a way. If that makes, I'm not sure if I'm quite make...

**Interviewer**\
No, no, you're, you're makin

## 29 \- 32:4923:216
ou've worked on?

**Interviewer**\
Hello? Hello. I can hear you now, did you hear my question? No, I think, I don't know who's having maybe network programs. I don't know if it's, it's me or if it's you, maybe I can check my security, my, sometimes like I'm getting like, getting lost along the way and getting like some breaks in between your sentences, I don't know. Gotcha. We can, we can keep going. If you want to reschedule too, and figure out what the connection issues are, that's fine as wel

## 30 \- 9:1639:152
, the standard, the standard library B-Tree, and then compare the, their values.

**Interviewer**\
Gotcha. Nice. That's a really clever way of testing. So you also mentioned you have, so we spoke a bit about address sanitizer. You also use Clippy and memory sanitizer, at least you, you mentioned that your survey response. Have those tools been particularly useful for you?

***Participant***\
Um, Clippy is really useful. I, I, I have it with my, you know, like the code CI. So every time I commit 

## 31 \- 22:3729:1652
 Unsafe, but we have encountered deadlock before, and that is always very difficult to debug, especially with spinlocks, which are required in the early or lowest level parts of the system before we have a task management subsystem. So a tool for that would be helpful, but that's not technically unsafe. It's just really obnoxious.

**Interviewer**\
Gotcha, gotcha. That makes sense.

***Participant***\
Yeah, if there was a tool that I think was easy to integrate into the project and could... I'm 

## 32 \- 26:3955:34
ly helpful.

**Interviewer**\
Gotcha. Gotcha. And then are there any particular problems that you face when ready and safe or verifying its correctness that your current tools can't solve for you?

***Participant***\
Hmm. Well, I mean, the biggest one facing us right now is we would love to run Miri, but actually run the [tool] test suite. Like, WASM has spec tests, we would love to run the spec tests in Miri, but we don't know how to do that right now. Like our closest approximation is going to

## 33 \- 2:182:217
e output slice.

**Interviewer**\
Mm hmm. Gotcha. So you're accessing this memory because you're using slices, you need direct, is it that you just need direct, like, into your indices? And that makes it such that you can't, like, which, I guess, where in particular is unsafe necessary there?

***Participant***\
Well, all the processing is written with SIMD instructions. 

**Interviewer**\
Oh, gotcha.

***Participant***\
Like, intrinsics are unsafe.

**Interviewer**\
Mm hmm.

***Participant***\


## 34 \- 22:3687:1763
I know we did use it more often. Oh, yeah. So here's an example. We have a callback for customizable mutex behavior, and we want to make sure that we drop the guard and then invoke this callback function that allows someone to know when a mutex has been dropped, for example, or something like that. So there isn't a way to represent that as far as I know without manually drop, but perhaps I'm missing something. And then we use it in some... I just realized I missed some. We use it in some devices

## 35 \- 8:1317:161
in practice so you have this pointer right back into the same location.

**Interviewer**\
Yeah gotcha yeah I think I'm following that yeah no for sure. Okay yeah I I'll I think with with that explanation and having the code is super helpful so I'll be able to think and take that apart a bit more later. That type of example is super awesome for us so thanks a ton for that.

***Participant***\
It's really messy.

**Interviewer**\
Yeah I mean that's yeah it's that's sort of the type of thing that w

## 36 \- 10:1814:212
he output is fine?

***Participant***\
No, I wouldn't. I don't think I've ever had to. And even then I would, I would be very, like if it was either myself or a co-worker that was having to go in and modify Bindgen generated stuff, I would be asking questions because that's really bad from long-term maintainability perspective, because then header file updates, you regenerate your bindings, you've lost your changes. You can kind of automate that stuff by like, you can write tests that generate t

## 37 \- 20:3264:1365
wrong. A lot of I do wish that some of the checkers were, I guess, more detailed in the reports, because a lot of times it can be kind of hard to nail down like what's going around where specifically. But a lot of the times, I think that's kind of more of a them sided issue than necessarily a Rust thing. And I do wish some of them had better platforms for it, because a lot of them don't work on Windows, which sucks. I'd like to be able to check out like all platforms. But yeah.

**Interviewer**\

## 38 \- 9:1516:1091
u reach the end of the chain, that drop will happen. And then you're going to pop up all all the items, all the strats, like pop all the strats, and we call the drop. So in this case, we want to enforce like a drop order, so that it will not have some stack overflow. In that case, we just manually drop.

**Interviewer**\
Gotcha. Okay. So just overriding Rust's default drop order to improve performance in cases where you have a very large data structure.

***Participant***\
Yeah, yeah, kind of.



## 39 \- 8:1203:665
at so it's nice and readable. Another thing which I don't like about C bindgen is just the compile time. It just adds another like 20 seconds of compile time, at least in my case because I have a library that doesn't actually have all that many dependencies and as soon as I pull C bindgen in it's like 20 seconds every time. So I just made it a feature and I switch it on whenever I want to and then I just diff the header and go from there.

**Interviewer**\
So to confirm, are you using the bindin

## 40 \- 17:2411:739
'm like, okay, it's easier to write memory safe code. But to call Rust memory safe is just like flagrantly, I think it's dangerous. I think it sets a bad precedent for the culture because I remember very distinctly once I was in Discord. And I was asking, you know, I was still like, I'm still really learning Rust. I've only been doing it for maybe like a year or two. And so I was asking some fellow Discorders, I was like, you know, do you run your production tests through Valgrind?

***Participa

## 41 \- 37:5684:263
eally came like, as I was in the very early stages of like figuring out the whole memory model for this thing, I think I had a conversation with someone there's an unofficial Rust community discord that's pretty popular. There's a channel in there called Dark Arts that lots of folks kind of sit around and talk about like the minutia of safety and soundness. And I think a conversation there really helped me understand that like you need that unsafe cell in order to basically tell the compiler lik

## 42 \- 37:5699:195
, is generic over all the game types.

**Interviewer**\
Okay, gotcha. So you'd just be allocating this rep or C struct. And then when you expose that struct to C, you take a pointer past the arc, but then you know that if you have it as that particular type, you can do the offset and safely access the arc because it's still there at the front of the allocation.

***Participant***\
Yeah, exactly.

**Interviewer**\
Gotcha, are there any other like tricks that are similar like that with pointer ari

## 43 \- 6:565:207
 to you got to make sure.

**Interviewer**\
Yeah. Interesting. So it seems like the way that you were describing the difference is really tied to the type system in the sense that you have this better assurance of functionality when working with Rust's trait system versus you mentioned where you're using templates. It tends to be that you don't really know if something works until you start using it. Could you give a bit more detail about that particular problem? What's an example of where somet

## 44 \- 6:580:1050
it for forcing people to uphold invariants on types, even if those invariants aren't explicitly required for memory safety, if it's just like correctness or something. And so I use them in that situation as well. So like when I'm building some new language level primitives, I'll use unsafe to make sure that everybody, you know, enforces contracts by wrapping things in unsafe blocks and justifying them properly so that you can take advantage of some large scale invariants or build up some new inv

## 45 \- 6:634:613
and that length may not actually be the proper length of the iterator. And people only realized this like after the fact, like, oh, we didn't put in a requirement that the length returned from this is actually the length of the iterator. And so there's this new trait called trusted length that actually does that. And it's an unsafe trait. So we end up with these two APIs, these two like iterator traits that we would use to control or like understand the length of the iterator introspect on it. A

## 46 \- 8:1317:41
 it were a moot self. But what I'm doing is basically taking it updating it and then putting it back in putting it back in practice so you have this pointer right back into the same location.

**Interviewer**\
Yeah gotcha yeah I think I'm following that yeah no for sure. Okay yeah I I'll I think with with that explanation and having the code is super helpful so I'll be able to think and take that apart a bit more later. That type of example is super awesome for us so thanks a ton for that.

***P

## 47 \- 35:5410:32
ncies that you choose and then auditing them for unsafe regularly?

***Participant***\
Occasionally I'll audit, occasionally I won't. If I'm interested in how something works, I'll take a peek, right?

**Interviewer**\
I see. And then when you're doing that sort of exploratory thing, that's when you start finding these cases.

***Participant***\
Yeah.

**Interviewer**\
What are some of the other patterns that you've seen where you're just like, I'm not so sure about that?

***Participant***\
Wel

## 48 \- 35:5461:68
ss, more inline assembly instructions and potentially foreign code for the bootloader and BIOS implementation, would that be of use to you? Or do you feel like...

***Participant***\
Part of the reason there is a difference in architecture between the host that Miri is running on and the target that the bootloader is meant to run on, right? Yeah. So Miri is designed to run in 16 bit mode assembly, right?

**Interviewer**\
I guess, let's say, hypothetically, you had a version of Miri that could .

## 49 \- 3:546:3500
eah, so that that is the norm. I'm hoping to build it is a high bar. It is not a bar I have myself followed that consistently in my code bases, because I haven't had time. But over time, I'm kind of hoping to build that kind of bar. And I'm really excited for more work in the review space. 

**Interviewer**\
Yeah. And I guess so, in particular, with some of the dynamic tools you mentioned, like Miri and the sanitizers, do you feel that the bug finding capability of those is adequate how they are

## 50 \- 14:2263:859
r now with the, and so it's more like code hygiene. I would say, uh, clipped in and, uh, it doesn't, I don't think it ever tells you to do things, do something different. It just tells you a different way you can do the same thing. And I guess that's the point of any lint is not going to, it shouldn't change the behavior of your code. It's no longer a lint. Yeah. But the ball trend, uh, especially in these, uh, as good, especially in those cases where I, uh, I, uh, have C and rust interactions. 

## 51 \- 22:3456:20
 limiting. So yeah, I would say that's a great example of taking something that's unsafe inherently and then kind of wrapping it up in a safe abstraction, using the power of Rust to do the borrow checking for us.

**Interviewer**\
Yeah, gotcha. And then you also mentioned that there are certain things that are bad, but that are not unsafe accessing a hardware timer. Is it the ...

***Participant***\
Yeah, so let me give you an example. Like if you, let's say you have the layout in memory of thos

## 52 \- 20:3132:19
s where they've been really, really great, really helpful versus situations where the output produced was wrong, or there was some other unhelpful aspect or like a usability concern that was a challenge for you?

***Participant***\
Yeah, I mean, sometimes, I mean, there's edge cases and bugs. I wish a lot of them were kind of better maintained, because a lot of them are kind of very much passively maintained. You know, they're not really like or which like, you know, no fault to the maintainers 

## 53 \- 9:1438:734
says, if you create a data, you just read it and without acquiring a read lock. And if you have a write, if you have a write operation, you need to first acquire the write lock and then write it. So how do you protect a reader to read data that is being read, concurrently? It will use a version number. And so before you read the data, you'll read it or version number. And after you read the data, you'll check that version number. If that version number changed, that means someone has modified it

## 54 \- 6:675:10d
 so I can make sure it works. Uh, that's basically what I use that for. Um, I'll give you, I'm sorry I'm sending so many links. Hopefully you enjoy this.

**Interviewer**\
Excellent. I really, really enjoy links. Please send all the links.

***Participant***\
Okay. So I wrote a blog post a while ago. Uh, I'll send the blog post and I'll send like the meaty stuff. This was the blog post, but for it, I made this, uh, JavaScript puzzle game. And part of that is it has a solver for the puzzles that'

## 55 \- 6:556:81
ices for read and good unsafe.**Interviewer**\
So the first question is what have been your motivations for learning Rust and for choosing to use it?

***Participant***\
I would say I started learning Rust probably back in like 2018. And the motivation was I was really tired of writing C++. I appreciated all of the like fine tuning and the low level control that I had for the language. But it just seemed like constantly the language was evolving in a direction that made it more complicated, more

## 56 \- 14:2302:470
 not really dependent on having, uh, the hardware instruction, uh, uh, implementation of all of these because there is a emulation. So that, you know, that's just a thought that came to me when we went through it and why didn't I check this in Miri? And I think it could be doable.**Interviewer**\
What have been your motivations for learning Rust and choosing to use it?

***Participant***\
Oh, that's a good question. So primarily, I was the C++ developer for a long time. Well, I am a C++ develope

## 57 \- 3:504:1594
And there's a mode when cbindgen where it can do that and also chase down crates, if you can tell it, look for look for this type and other crates and stuff, it's not from here. And that when it works, it works. But when it doesn't work, it's a mess. Because cbindgen does not understand all of Rust, and it can't generate FFI for all of Rust anyway. So my general opinion is that if you're building a tool where your source of truth is Rust code, make the source of truth be very explicitly tagged R

## 58 \- 37:5678:501
and your C code has somewhere along the way called into Rust now, right? So up, if you walk up the stack somewhere, you're gonna find a C frame that represents the game and it's holding that lock, but you need a reference to something in Rust. That's where like, we kind of assume that, well, the C side may be holding a pointer to it too, so like you may be aliasing somewhere on the C side, but we just know that we do have this global lock and the C code is the only thing there. The C code itself

## 59 \- 31:4661:26
*\
Gotcha. Was there like a particular pre and slash post condition that was, was the issue there?

***Participant***\
I think it had to do with me passing the alarm, reporting the alignment and passing it.

**Interviewer**\
Gotcha. So was it just like the wrong alignment value then?

***Participant***\
Yeah, I think, yeah, I think I, I think what I did is I had some code that, my code for figuring out that value was incorrect and I was passing some undefined value to it. And it worked most of t

## 60 \- 22:3687:1022
ey had a guaranteed drop order based on the declaration order of fields in a struct. Before that, we had to use manually drop everywhere that we wanted to impose an ordering on how things were dropped. Now, let me see, where do I use it? So now we use it in some synchronization primitives like read write blocks to make sure that we are dropping the guard before we... So we have some weird read write lock primitives where we're getting additional information about the number of readers and writer

## 61 \- 32:4965:199
ent maybe, it's a common problem.

**Interviewer**\
Gotcha. Gotcha. And then when would you use manually drop, I guess, is like, what, what use cases would you have for that? Are they generally in, with like Rust allocations, or are there situations where you've used that with allocations coming in from like another language?

***Participant***\
Yeah, yeah. Maybe, it can be, maybe in session, or maybe when you want to do some, okay, removal of elements. Gotcha.

**Interviewer**\
And then the las

## 62 \- 31:4670:1023
hen I either upgrade the, you know, upgrade half bars or these other open source libraries, and then I need to call a new function and I have to go and open that unsafe code. But it's like these, the times that I touch this stuff are like probably, you know, months and, you know, months in between each other.

**Interviewer**\
Gotcha. Gotcha. Okay. Yeah. That makes sense. I think, oh, there's one particular question that I had. Sorry, I just lost my train of thought. Gotcha. So was the, I guess 

## 63 \- 2:203:133
t understand this, that functions can have a target feature attribute. 

**Interviewer**\
Mm hmm.

***Participant***\
If they have this attribute, it means that they can, this attribute can say, for example, target feature ADX. For example, if they have this function, they can call other functions, this attribute, they can call other functions that have ADX as an attribute.

**Interviewer**\
Mm hmm.

***Participant***\
Or, more correctly, the compiler can inline the code from these functions int

## 64 \- 22:3762:195
some future work or something or TBD.

**Interviewer**\
Yeah, so my area is generally in, I am kind of a verification guy. And I am trying to figure out what the problems are currently surrounding use of unsafe, and sort of like how unsafe is used more broadly, because there have been a lot of studies doing like quantitative analysis of unsafe, how much it's used where it's used but not about like the actual experience of having to work with it. So I'm hoping to get as many perspectives as possi

## 65 \- 19:2888:6
ple also rightfully have few concerns that maybe this could be useful for performance in the future. But I think that the potential compiler optimization impact is going to be too small to justify having this foot gone around.

**Interviewer**\
Gotcha.

***Participant***\
I'm not going to be the person that will make the call or will be around to make the call. That's probably going to be on the operational semantics team. As I already mentioned, I think I don't know if you have a link already, 

## 66 \- 2:140:107
of it, but I am fairly sure it should be fine. 

**Interviewer**\
Gotcha

***Participant***\
You know, as sure as you can be.

**Interviewer**\
So you mentioned ...So in the list of types in the survey, you mentioned mostly using slices from your previous response. I'm guessing that was related to the UEFI interface where you're passing C-Strings.

***Participant***\
No. No, that was related to the memory, sorry, the image decoding functions.

**Interviewer**\
Oh, gotcha. Yeah. Let's talk about 

## 67 \- 37:5774:230


***Participant***\
I think most of the biggest bugs came kind of as I was finishing the like safety and guardrails, right? So like the first versions of the deallocators didn't have the kind of table to check and make sure that like this pointer is valid. And that caused kind of interesting, difficult to track down crashes because you crash in Rust and then it unwinds and you've got the like FFI boundary stuff. So like those crashes, and I think in the very early days, I didn't realize actuall

## 68 \- 31:4368:61
algorithm or it can be just like do some fencing or something. Okay, that's it.**Interviewer**\
What have been your motivations for learning Rust and choosing to use it?

***Participant***\
What happened was, I realized I needed to do something in, in WebAssembly, because we want some, again, this is, I'm going to, this is what I, it would be so much easier if I could talk about the details of what I'm working on. What happened was, an application we needed to build, had to be in WebAssembly, ha

## 69 \- 8:1326:58
sometimes. Yeah I guess along those lines just a couple questions you mentioned you use Box and once cell in unsafe contexts. Could you describe a bit more about those two?

***Participant***\
Box all the time. Unsafe I don't remember probably I must have picked it so I must have thought during the survey yeah okay oh yeah it was it was once cell oh once I'll have to grab I'll have to grab through my code and check I probably yeah Box is it's it's pretty common because so Box and Rc/Arc they're 

## 70 \- 14:2076:420
tried to just steal them instead. Yeah, this is really low level stuff where you're actually writing into the re allocating a vector table for the CPU. What's going on here. I'm not enabling a DMA for some reason. Reboot magic. So this microcontroller, it will, it doesn't erase the RAM during reboot. So then I have certain sequences that okay, say you want to update you want to flash other firmware or you want to go into sleep mode. And this handle is just write a magic value to RAM. And then wh

## 71 \- 20:3216:591
generally speaking, like calling a function that later invalidates the reference that you created, you know, or the pointer that you created. Even though like in practice, it's not actually an issue. It's like a kind of a model issue. Yeah. Or an issue on a model level.

**Interviewer**\
Gotcha. Gotcha. Speaking of models and just the general architecture of un-safety, could you describe the extent to which un-safe is used within like, in particular, I'm thinking of the JIT code. Are there any a

## 72 \- 26:3937:744
very different there, but all that being said, ASAN, I might have misunderstood the question on the questionnaire, but ASAN is practically worthlessto us because we never found any bugs in ASAN. Like ASAN is generally intended for like C and C. ASAN is typically intended for like C and C plus plus. So if you just have memory pointers everywhere, everything's unsafe. Who knows what? So for us, we actually have never really had any issues with ASAN. We've never had use after frees.. We've never re

## 73 \- 7:827:202
r multi-threaded primitives?

***Participant***\
Amusingly, using more unsafe made it less fragile. I was trying to avoid various uses of unsafe before. And instead, you use things like Boxes and vectors to abstract reallocations. But at some point, I needed to deallocate memory. So I was using the raw deallocation API. But I did something wrong. And I wasn't even clear on what I did wrong. But in the end, it was simpler to use the raw allocation and deallocation API directly instead of trying t

## 74 \- 22:3441:100
 an all pointer. And how did you encode those as types in this safe interface? Yeah, hearing more about that would be interesting.

***Participant***\
Oh, yeah. Yeah...the main idea is that you want to abide by memory safety rules when you have a region of memory that has been mapped and allocated and then mapped, right? So in [os], we have a bunch of sort of unique rules where, you know, a page needs to be globally unique, a frame needs to

## 75 \- 7:887:297
started using interrupts, we needed to synchronize our accesses to shared memory between the interrupts and the main program. And for that, we needed to implement our own mutexes because there's no operating system or anything interesting there that you could reuse. And for implementing those, we needed unsafe cell to be able to have interior mutability and then figure out some locking scheme around that to soundly access that shared memory.

**Interviewer**\
Has use of RefCell ever been a perfo

## 76 \- 39:6039:53
iple references to be contained in a particular body or maybe when I want to, maybe I have concurrent and multi threaded application. So in such instances, then it's a preference.

**Interviewer**\
Sure. That makes sense. Um, and then when do you use lazy cell?

***Participant***\
Um, with lazy cell, okay. Don't know. Maybe it's mostly, but maybe it's useful for me. Uh, when I need to store a value, um, uh, on the heap or other than me, then we prefer to store a value in a heap or other than. 


## 77 \- 3:516:2739
very much like C++ has choices on how to do this and Rust has choices on how to do this. And they haven't necessarily picked the same thing. There's no standard on this. There can't be a standard on this because different languages kind of have different notions of destructors and stuff like that. So yeah, so this is a bit of a mess. And the end result of this is if you're doing FFI, the only things you should pass by value are copy types. Or the only things you should pass by value are primitiv

## 78 \- 8:1149:489
the comment which is wrong, or is the implementation that is wrong? Because comments don't have a compiler. When you chuck enough people at a code base, comments don't really get read all that much. So there's always this thing of, is it worthwhile putting in a comment that may or may not be maintained at this point in time? It's just a pragmatic thing and it's a call you need to make. So I don't actually advocate documenting every piece of unsafe because of that.

**Interviewer**\
Gotcha. Inter

## 79 \- 26:3805:275
d machine code, a trusted machine code, but from an output of a runtime component. So like the wasm is untrusted, but the output of the compiler is trusted. So like we can, we can't trust, we like basically WebAssembly is like guaranteed sandBox semantics to start at a language level, but then we're running it through a compiler which claims that it actually compiles a wasm successfully, but it can't have bugs. So effectively, like we've had bugs in historically, we have the reason to believe it

## 80 \- 17:2501:2
ng to do like half the features that live PNG actually has. And I was like, well, that's lame because it's kind of a downgrade, but then you use the PNG and then it has like long jump in it. And you're just like, uh, it's so hard.

**Interviewer**\
So speaking of difficult programming patterns, this next question is pretty broad again. Describe a bug that you face that involved unsafe Rust and sort of, if you can think of a particular example, go into how it manifested and then what the, what th

