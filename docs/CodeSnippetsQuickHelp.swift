//
//  CodeSnippets.swift
//  DoccSandbox
//
//  Created by Zakk Hoyt on 2024-11-25.
//  
//  https://github.com/hatch-mobile/CodeSnippets

public actor CodeSnippets {
    /// Hey there @iosDevs. I've been digging through `Xcode`'s and `DocC`s articles on writing documentation.
    ///
    /// I found that the majority of the syntax only works in `Swift Playgrounds`. I tried them all out to see what worked well and what didn't.
    /// I then paired them up with related `Placeholders` for a list of `Code Snippets` big and small. These fall into 3 categoryies:
    /// Callouts, Markdown, and Placeholders,
    ///
    /// I use these quite frequently and
    /// thought they could be useful for others as well.
    ///
    /// # Composition
    /// - **Callouts:** These "built in" parameters (EX: `- Note:`, `- Parameter:`) are what's known as `Callouts` and are part
    /// of the [Markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html#//apple_ref/doc/uid/TP40016497-CH2-SW1)
    /// syntax. There are 25 of them to choose from. ![callouts](https://i.imgur.com/whD2DYs.png)
    /// - **Markdown:** If you can't find just the right `Callout` you can build your own using `Markdown` support.
    /// Most of Markdown's Basic Syntax is supported including links, images, and flavored code fences. ![markdown](https://i.imgur.com/124yBRy.png)
    /// - **Placeholder:** Is the temporary string that can be typed over. EX: The `NNNN` in this Jira Ticket snippet. ![Jira Ticket snippet](https://i.imgur.com/fpohYdc.png)
    ///
    /// # Invoking
    /// - Invariant: Because these snippets follow a convention we can quickly locate and consume them. Names all begin with `hatch_` and completion strings with `__`.
    ///
    /// To open the Snippets menu and filter to team snippets these team snippets:
    /// * Type `__` into any empty line in a Swift file. Every snippets' completion strings begins with `__`. Append `qc` to narrow to `quick comments` snippets.
    /// ![__qh](https://i.imgur.com/8giX9pD.png)
    /// * Type `cmd`+`shift`+`L` then `hatch`. Every team snippets' name begins with `hatch`.
    /// ![cmd+shift+L](https://i.imgur.com/BwLuOMg.png)
    ///
    /// # CodeSnippets Repository
    ///
    /// - Experiment: Snippets and installer are hosted on [hatch-mobile](https://github.com/hatch-mobile/CodeSnippets) if you'd like to give them a try or contribute.
    /// - Version: `1.0.1`
    ///
    /// # References
    /// ## Source vs Rendered Appearance
    /// * All ["Callouts" (documentation arguments)](https://i.imgur.com/eOdQQjv.png)
    /// * [Supported and Unsupported Markdown](https://i.imgur.com/LC7QEM6.png)
    /// * [Tracking TODO and FIXME with #warning() ](https://i.imgur.com/V7RkwCq.png)
    /// *
    ///
    /// ## Rendered
    /// * [This rendered in Quick Help](https://i.imgur.com/5PMgYTG.png)
    /// * [This rendered in DocC](https://i.imgur.com/2M2Elnr.png)
    ///
    /// ## Documentation
    /// * [CodeSnippets Repository (hatch-mobile)](https://github.com/hatch-mobile/CodeSnippets)
    /// * [Document your Swift code using DocC](https://www.swift.org/documentation/docc/)
    /// * [Writing Documentation](https://developer.apple.com/documentation/xcode/creating-organizing-and-editing-source-files)
    ///     * [Writing symbol documentation in your source files](https://developer.apple.com/documentation/xcode/creating-organizing-and-editing-source-files)
    /// * [Callouts for Quick Comments](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/Attention.html#//apple_ref/doc/uid/TP40016497-CH29-SW1)
    /// * [DocC: API Documentation](https://developer.apple.com/documentation/docc/api-reference-syntax/)
    /// * [Markdown Syntax](https://www.markdownguide.org/cheat-sheet/)
    public func aboutTeamCodeSnippets() {}
}

