# Getting started

As with any compiled language, you need a proper set of tools to compile, run and debug your Move applications. Since this language is created for blockchains and used only within them, running scripts off-chain is a non-trivial task: every module will require an environment, account handling and compile-publishing system.

To simpify development of Move modules we've created [Move IDE](https://github.com/damirka/vscode-move-ide) extension for Visual Studio Code. This extension will help you cope with environment requirements. Use of this extension is highly recommended as it will handle the build/run environment for you, hence will let you focus on learning Move language instead of struggling with the CLI environment. This extension also includes Move syntax highlighting and run environment to help you debug your applications before going public.

## Install Move IDE

To install it you'll need:

1. VSCode (version 1.43.0 and above) - you can [get it here](https://code.visualstudio.com/download); if you already have one - proceed to the next step;
2. Move IDE - once VSCode is installed, follow [this link](https://marketplace.visualstudio.com/items?itemName=damirka.move-ide) to install the newest version of IDE.

### Setup environment

Move IDE proposes a single way of organizing your directory structure. Create a new directory for your project and open it in VSCode. Then setup this directory structure:

```
modules/   - directory for our modules
scripts/   - directory for transaction scripts
out/       - this directory will hold compiled sources
```

Also you'll need to create a file called `.mvconfig.json` which will configure your working environment. This is a sample for `libra`:

```json
{
    "network": "libra",
    "sender": "0x1"
}
```

Alternatively you can use `dfinance` as network:

```json
{
    "network": "dfinance",
    "sender": "0x1"
}
```

> dfinance uses bech32 'wallet1...' addresses, libra uses 16-byte '0x...' addresses. For local runs and experiments 0x1 address is enough - it's simple and short. Though when working with real blockchains in testnet or production environment you'll have to use correct address of the network you've chosen.

## Your very first application with Move

Move IDE allows you to run scripts in a testing environment. Let's see how it works by implementing `gimme_five()` function and running it inside VSCode.

### Create module

Create new file called `hello_world.move` inside `modules/` directory of your project.
```Move
// modules/hello_world.move
address 0x1 {
module HelloWorld {
    public fun gimme_five(): u8 {
        5
    }
}
}
```

> If you decided to use your own address (not `0x1`) - make sure you've changed 0x1 in this file and the one below

### Write script

Then create a script, let's call it `me.move` inside `scripts/` directory:
```Move
// scripts/run_hello.move
script {
    use 0x1::HelloWorld;
    use 0x1::Debug;

    fun main() {
        let five = HelloWorld::gimme_five();

        Debug::print<u8>(&five);
    }
}
```

Then, while keeping your script open follow these steps:
1. Toggle VSCode's command palette by pressing `⌘+Shift+P` (on Mac) or `Ctrl+Shift+P` (on Linux/Windows)
2. Type: `>Move: Run Script` and press enter or click when you see the right option.

Voila! You should see the execution result - log message with '5' printed in debug. If you don't see this window, go through this part again.

Your directory structure should look like this:
```
modules/
  hello_world.move
scripts/
  run_hello.move
out/
.mvconfig.json
```

> You can have as many modules as you want in your modules directory; all of them will be accessible in your scripts under address which you've specified in .mvconfig.json
