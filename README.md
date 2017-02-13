# bikefit
Bike Fit

Here's a sample account to use to get started.  (You have to log in to get access to some features.)
User: drew@generalui.com
Password: password

# Building, open bikefit.xcworkspace

## If you are running bundler (e.g. max is running bundler):

FYI see Gemfile in the root of the project.  Also see: https://guides.cocoapods.org/using/a-gemfile.html

(This is instead of running pod install, etc.)

(Note: you might have to remove Podfile.lock before doing these steps)

```
bundle install
bundle exec pod install
bundle exec pod update    (...?  haven't tried this)
open bikefit.xcworkspace/
```

(Note: this will create Gemfile.lock)

## If you are NOT running bundler

```
pod install
```
(If you get an error like this after running pod install, you're probably running bundler, and you should follow the instructions above for machines running bundler:)
  /Users/max/.rvm/gems/ruby-2.2.4/gems/bundler-1.14.4/lib/bundler/rubygems_ext.rb:45:in 'full_gem_path': uninitialized constant Bundler::Plugin::API::Source (NameError)

```
pod update
open bikefit.xcworkspace/
```
