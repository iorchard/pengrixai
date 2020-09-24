sudo rbd bench \
                --pool rbdbench \
                --image image-000 \
                --io-size 4096 \
                --io-threads 1 \
                --io-total $(echo $((1024*1024*1024*40))) \
                --io-pattern rand \
                --io-type write
