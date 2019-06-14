using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libscsindir"], :indirect),
    LibraryProduct(prefix, ["libscsdir"], :direct),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaOpt/SCSBuilder/releases/download/v2.0.2-1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-gnu-gcc4.tar.gz", "411783890e3519114ab3133dc58589b9763f6e4d80f105af6cf2bac790473f3b"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-gnu-gcc7.tar.gz", "82190c60d433e2c3b66b08356719588b8512bcafd62739131a109e9d655aa7db"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-gnu-gcc8.tar.gz", "9bfd96bc766528e94b0b2c38c1373c59b0cd83c556aa5261d60c71478542df46"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-musl-gcc4.tar.gz", "2d17f72c4d0d6b0486aec34288b22f9f75d5c5b428697290b2f3ed5ac9ec8ddd"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-musl-gcc7.tar.gz", "60e0cd511fc7e4fd8d44909a047b5219aee63aa6f62f0b4c43a15f8e9d5737c6"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.aarch64-linux-musl-gcc8.tar.gz", "09ec967c0d8777bebb4c0c1694b5a2345cf9ec719bb44ab41360248ac1565787"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-gnueabihf-gcc4.tar.gz", "0734aca73fe06e7f07756b0aaadeaaf41fd128e3d140aac20f3668c7ae53c755"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-gnueabihf-gcc7.tar.gz", "dfe186d72f2b5dddf8b49062fecd75282cf0b9c29b86ee3b447dd572c65b90f9"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-gnueabihf-gcc8.tar.gz", "518ae1d397563279d83ca58f23a9b8e974714e7538de7153ffc5a9e62c6dceec"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-musleabihf-gcc4.tar.gz", "5c538e7b3b8c07992e16cd76d4a5390766d2245d56d097bd8b56cfc17390f4b0"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-musleabihf-gcc7.tar.gz", "fc5b7958133d9e543cb0d011fbd9cb31cde74e4bcd8daddd1fc378ba69143060"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.arm-linux-musleabihf-gcc8.tar.gz", "56909eddfb490abd562795e9d93d63539b1f137bbce522e37364551be20ef1f3"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-gnu-gcc4.tar.gz", "f6f519b7999709a970ea3acfa69e444c653da4bf61f1cd6d78c2c0918021f66e"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-gnu-gcc7.tar.gz", "a50901c719627d98527b55fedae88b03a1a643d5fe21a155acd02b72d2000a21"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-gnu-gcc8.tar.gz", "eff5108d6bae6512a2c08c2d1421b0edee0558c08e0585ca427f9b54353b80cb"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-musl-gcc4.tar.gz", "78013625c7ce4cc09dacc2c1d0cf0e8df78dfafab746237aa4d66725d2bf8d2b"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-musl-gcc7.tar.gz", "8bc8ea9fa992dfca1f9e8d79b0d662d702f51e2b364967a390a9313dc7777e8b"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-linux-musl-gcc8.tar.gz", "921e53047e38e83688ca4d68edffe4f39362cb37060821752469f9053bc4dacf"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-w64-mingw32-gcc4.tar.gz", "97bcc6778046f1b5ccbf7948931685440d188722b0618585d77e44d31d6ee9a6"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-w64-mingw32-gcc7.tar.gz", "d6da6f19db76a6df3b5c3e4db4ac4b716ace8c92e010bb76d84817f0eeff9c2e"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.i686-w64-mingw32-gcc8.tar.gz", "cd1ff27dd513b396cf9bf40c686ded9220136b8e7a6bea57dd10f8d1a688eae1"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.powerpc64le-linux-gnu-gcc4.tar.gz", "e765685ccefdd33de55c47573470a65a683f034123e6cea4c484458010f6e84c"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.powerpc64le-linux-gnu-gcc7.tar.gz", "9f313ae374660db504f054df77ee974d8f618f7acdf0abfe0c70db3fb7b70287"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.powerpc64le-linux-gnu-gcc8.tar.gz", "bae7ce077583bbb1095edf958ee3084dfa927b32962788fe74d700f745d08be4"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-apple-darwin14-gcc4.tar.gz", "d1df117089f95b3ed78dfe7aed3843253b442a95465029bdffeeea96bafe83e9"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-apple-darwin14-gcc7.tar.gz", "5aeea5fa1e72987414a19839e0f962d6b9948064008ea2894021a8cd34d835c0"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-apple-darwin14-gcc8.tar.gz", "6f8c11d06d7d19b8f77f4eb894add4cc157d6df7a7752d053b72b78a9ea2e0b1"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-gnu-gcc4.tar.gz", "39047597ecd8bab58d54d6d80a0f8db94be916c77152f8843aa8f017b601b284"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-gnu-gcc7.tar.gz", "2185fa1bd3b8a70b18fc2474a298edab54fb0624884d337aa7fb9013f500f248"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-gnu-gcc8.tar.gz", "91530d5673d50090b6b09cb6c5eaf2f611c221b63df5e5a22be52b576e4555e2"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-musl-gcc4.tar.gz", "ece44ac4a8cb05a7c9cb7493644968176088dcf56ad124a9d7254fb9dbcb20a4"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-musl-gcc7.tar.gz", "131b11cdcd8c327c6faf3611467428d5728e243ca9f1ae8cf8c8721e1ae4eea4"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-linux-musl-gcc8.tar.gz", "675d6c2eb9a8a1e6f6d6ad960177ef08ec27f7438995b923e71a99bea8919738"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-unknown-freebsd11.1-gcc4.tar.gz", "8b776b1d2bee4a20dcb33ba419a40dcddf0afc7bdbe4f48c2894968171567c5a"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-unknown-freebsd11.1-gcc7.tar.gz", "64004ecfaca8e2ac77bc061ef4074d2236f21b370d79a362b559f729e5130ed0"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-unknown-freebsd11.1-gcc8.tar.gz", "9dca29b3fe1d0adfb96b4e3c2852adc5df074fe2c79de86145300ea2eb5a4d82"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-w64-mingw32-gcc4.tar.gz", "813e476317d65883818c6250f50697b68c7ff4145f0b8bd03c3b56c44e127497"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-w64-mingw32-gcc7.tar.gz", "5a846ccd3173fa83ad4ab8817d2624f316444ac05a2c6a9199c08643269ab4f4"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/SCSBuilder.v2.0.2.x86_64-w64-mingw32-gcc8.tar.gz", "ff56d16db12b52c1dab0b181123de0c5a6f0053a7a9c8dd97b4bfae0f3cc0204"),
)

this_platform = platform_key_abi()
                  
custom_library = false
if haskey(ENV,"JULIA_SCS_LIBRARY_PATH")
    custom_products = [LibraryProduct(ENV["JULIA_SCS_LIBRARY_PATH"],product.libnames,product.variable_name) for product in products]
    if all(satisfied(p; verbose=verbose) for p in custom_products)
        products = custom_products
        custom_library = true
    else
        error("Could not install custom libraries from $(ENV["JULIA_SCS_LIBRARY_PATH"]).\nTo fall back to BinaryProvider call delete!(ENV,\"JULIA_SCS_LIBRARY_PATH\") and run build again.")
    end
end

if !custom_library
    # Install unsatisfied or updated dependencies:
    unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)

    dl_info = choose_download(download_info, this_platform)
    if dl_info === nothing && unsatisfied
        # If we don't have a compatible .tar.gz to download, complain.
        # Alternatively, you could attempt to install from a separate provider,
        # build from source or something even more ambitious here.
        error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
    end

    # If we have a download, and we are unsatisfied (or the version we're
    # trying to install is not itself installed) then load it up!
    if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
        # Download and install binaries
        install(dl_info...; prefix=prefix, force=true, verbose=verbose)
    end
 end
                    
# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
