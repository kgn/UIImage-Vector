# UIImage-Vector

UIImage category for dealing with vector formats like PDF and icon fonts.

## Usage

Use an icon font:

``` objc
UIFont *font = [UIFont fontWithName:@"MyIconFont" size:28.0f];
UIImage *gear = [UIImage iconWithFont:font named:@"gear"
                        withTintColor:[UIColor whiteColor] clipToBounds:NO forSize:28.0f];
```

Use a PDF:

``` objc
UIImage *gear = [UIImage imageWithPDFNamed:@"gear"
                             withTintColor:[UIColor whiteColor] forHeight:28.0f];
```

## Installation

Simply add the files in `UIImage-Vector` to your project and link `CoreText.framework`.
