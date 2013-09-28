# UIImage-Vector

UIImage category for dealing with vector formats like PDF and icon fonts.

## Usage

Use an icon font PDF:

``` objc
UIImage *gear = [UIImage iconWithFont:font named:@"g"
                        withTintColor:[UIColor whiteColor] clipToBounds:NO forSize:28.0f];
```

Use a PDF:

``` objc
UIImage *gear = [UIImage imageWithPDFNamed:@"gear" withTintColor:[UIColor whiteColor] forHeight:28.0f];
```
