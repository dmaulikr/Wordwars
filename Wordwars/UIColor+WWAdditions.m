//
//  UIColor+WWAdditions.m
//  Wordwars
//
//  Created by Alex Winston on 12/3/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import "UIColor+WWAdditions.h"

@implementation UIColor (WWAdditions)

void ConvertRGBtoHSL( const CGFloat * components, CGFloat * hslComponents )
{
    CGFloat r, g, b;
    
    r = components[0];
    g = components[1];
    b = components[2];
    
    CGFloat h, s, l;
    
    CGFloat max = MAX( r, MAX( g, b ) );
    CGFloat min = MIN( r, MIN( g, b ) );
    
    l = ( max + min ) / 2;
    
    if( max == min )
    {
        s = 0;
        h = 0;
    }
    else
    {
        if( l < 0.5 )
        {
            s = ( max - min ) / ( max + min );
        }
        else
        {
            s = ( max - min ) / ( 2.0 - max - min );
        }
        
        if( r == max )
            h = ( g - b ) / ( max - min );
        else if( g == max )
            h = 2.0 + ( b - r ) / ( max - min );
        else
            h = 4.0 + ( r - g ) / ( max - min );
        
        h *= 60.0;
        if( h < 0 )
            h += 360;
    }
    
    hslComponents[0] = MAX( 0, MIN( 360.0, h ) );
    hslComponents[1] = MAX( 0, MIN( 1.0, s ) );
    hslComponents[2] = MAX( 0, MIN( 1.0, l ) );
    
}

void ConvertHSLtoRGB( const CGFloat * components, CGFloat * rgb )
{
    CGFloat h = components[0],
    s = components[1],
    l = components[2];
    CGFloat t1, t2;
    
    if( s == 0 )
    {
        rgb[0] = rgb[1] = rgb[2] = l;
    }
    else
    {
        if( l < 0.5 )
            t2 = l * ( 1 + s );
        else
            t2 = ( l + s ) - ( l * s );
        t1 = ( 2 * l ) - t2;
        
        h /= 360.0;
        
        rgb[0] = h + ( 1.0 / 3.0 );
        rgb[1] = h;
        rgb[2] = h - ( 1.0 / 3.0 );
        
        for( int ix = 0; ix < 3; ix++ )
        {
            if( rgb[ix] < 0.0 )
                rgb[ix] += 1.0;
            else if( rgb[ix] > 1.0 )
                rgb[ix] -= 1.0;
            
            if( rgb[ix] * 6.0 < 1 )
                rgb[ix] = t1 + ( ( t2 - t1 ) * 6 * rgb[ix] );
            else if( 2 * rgb[ix] < 1 )
                rgb[ix] = t2;
            else if( 3 * rgb[ix] < 2 )
                rgb[ix] = t1 + ( ( t2 - t1 ) * ( ( 2.0 / 3.0 ) - rgb[ix] ) * 6.0 );
            else
                rgb[ix] = t1;
        }
    }
    
    for( int ix = 0; ix < 3; ix++ )
        rgb[ix] = MAX( 0, MIN( 1, rgb[ix] ) );
}

- (UIColor *)colorByDarkeningColor:(CGFloat)amount
{
    CGColorRef clr = [self CGColor];
    CGColorSpaceRef clrSpace = CGColorGetColorSpace( clr );
    
    const CGFloat * components;
    
    CGColorSpaceModel model = CGColorSpaceGetModel( clrSpace );
    
    if( model != kCGColorSpaceModelRGB && model != kCGColorSpaceModelLab )
        return self;
    
    components = CGColorGetComponents( clr );
    CGFloat hslComponents[3];
    CGFloat rgbComponents[3];
    
    if( model == kCGColorSpaceModelRGB )
        ConvertRGBtoHSL( components, hslComponents );
    
    hslComponents[1] -= amount; // saturation
    hslComponents[2] -= amount; // lightness
    
    if( model == kCGColorSpaceModelRGB )
    {
        ConvertHSLtoRGB( hslComponents, rgbComponents );
        return [UIColor colorWithRed: rgbComponents[0] green: rgbComponents[1] blue: rgbComponents[2] alpha: CGColorGetAlpha( clr )];
    }
    
    
    return [UIColor colorWithHue: hslComponents[0] saturation: hslComponents[1] brightness: hslComponents[2] alpha: CGColorGetAlpha( clr )];
}

@end
