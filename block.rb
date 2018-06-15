require 'digest'
require 'pp'      ## pp = pretty print


class Block
  attr_reader :data
  attr_reader :prev
  attr_reader :difficulty
  attr_reader :time
  attr_reader :nonce  # number used once - lucky (mining) lottery number

  def hash
    Digest::SHA256.hexdigest( "#{nonce}#{time}#{difficulty}#{prev}#{data}" )
  end

  def initialize(data, prev, difficulty: '0000' )
    @data         = data
    @prev         = prev
    @difficulty   = difficulty
    @nonce, @time = compute_hash_with_proof_of_work( difficulty )
  end

  def compute_hash_with_proof_of_work( difficulty='00' )
    nonce = 0
    time  = Time.now.to_i
    loop do
      hash = Digest::SHA256.hexdigest( "#{nonce}#{time}#{difficulty}#{prev}#{data}" )
      if hash.start_with?( difficulty )
        return [nonce,time]    ## bingo! proof of work if hash starts with leading zeros (00)
      else
        nonce += 1             ## keep trying (and trying and trying)
      end
    end # loop
  end # method compute_hash_with_proof_of_work

end # class Block

b0 = Block.new( 'Hello, Cryptos!', '0000000000000000000000000000000000000000000000000000000000000000' )
b1 = Block.new( 'Hello, Cryptos! - Hello, Cryptos!', b0.hash )
b2 = Block.new('Alexis', b1.hash)
b3 = Block.new( 'Data Data Data Data', b2.hash )


## shortcut convenience helper
def sha256( data )
  Digest::SHA256.hexdigest( data )
end

pp b0.hash == sha256( "#{b0.nonce}#{b0.time}#{b0.difficulty}#{b0.prev}#{b0.data}" )
# => true
pp b1.hash == sha256( "#{b1.nonce}#{b1.time}#{b1.difficulty}#{b1.prev}#{b1.data}" )
# => true
pp b2.hash == sha256( "#{b2.nonce}#{b2.time}#{b2.difficulty}#{b2.prev}#{b2.data}" )
# => true
pp b3.hash == sha256( "#{b3.nonce}#{b3.time}#{b3.difficulty}#{b3.prev}#{b3.data}" )
# => true

# check proof-of-work difficulty (e.g. '0000')
pp b0.hash.start_with?( b0.difficulty )
# => true
pp b1.hash.start_with?( b1.difficulty )
# => true
pp b2.hash.start_with?( b2.difficulty )
# => true
pp b3.hash.start_with?( b3.difficulty )
# => true

## check chained / linked hashes
pp b0.prev == '0000000000000000000000000000000000000000000000000000000000000000'
#=> true
pp b1.prev == b0.hash
#=> true
pp b2.prev == b1.hash
#=> true
pp b3.prev == b2.hash
#=> true

# check time moving forward; timestamp always greater/bigger/younger
pp b1.time >= b0.time
#=> true
pp b2.time >= b1.time
#=> true
pp b3.time >= b2.time
#=> true
pp Time.now.to_i >= b3.time   ## back to the future (not yet) possible :-)
#=> true
