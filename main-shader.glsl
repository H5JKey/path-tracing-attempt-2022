void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec4 data = texelFetch(iChannel0, ivec2(fragCoord), 0);
    vec3 col = data.rgb / data.w;
    
    // Output to screen
    fragColor = vec4(col,1.0);
}
