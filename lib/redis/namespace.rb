require 'redis'

class Redis
  class Namespace
    # The following table defines how input parameters and result
    # values should be modified for the namespace.
    #
    # COMMANDS is a hash. Each key is the name of a command and each
    # value is a two element array.
    #
    # The first element in the value array describes how to modify the
    # arguments passed. It can be one of:
    #
    #   nil
    #     Do nothing.
    #   :first
    #     Add the namespace to the first argument passed, e.g.
    #       GET key => GET namespace:key
    #   :all
    #     Add the namespace to all arguments passed, e.g.
    #       MGET key1 key2 => MGET namespace:key1 namespace:key2
    #   :exclude_first
    #     Add the namespace to all arguments but the first, e.g.
    #   :exclude_last
    #     Add the namespace to all arguments but the last, e.g.
    #       BLPOP key1 key2 timeout =>
    #       BLPOP namespace:key1 namespace:key2 timeout
    #   :alternate
    #     Add the namespace to every other argument, e.g.
    #       MSET key1 value1 key2 value2 =>
    #       MSET namespace:key1 value1 namespace:key2 value2
    #
    # The second element in the value array describes how to modify
    # the return value of the Redis call. It can be one of:
    #
    #   nil
    #     Do nothing.
    #   :all
    #     Add the namespace to all elements returned, e.g.
    #       key1 key2 => namespace:key1 namespace:key2
    COMMANDS = {
      "auth"             => [],
      "bgrewriteaof"     => [],
      "bgsave"           => [],
      "blpop"            => [ :exclude_last ],
      "brpop"            => [ :exclude_last ],
      "dbsize"           => [],
      "decr"             => [ :first ],
      "decrby"           => [ :first ],
      "del"              => [ :all   ],
      "exists"           => [ :first ],
      "expire"           => [ :first ],
      "flushall"         => [],
      "flushdb"          => [],
      "get"              => [ :first ],
      "getset"           => [ :first ],
      "hset"             => [ :first ],
      "hget"             => [ :first ],
      "hdel"             => [ :first ],
      "hexists"          => [ :first ],
      "hlen"             => [ :first ],
      "hkeys"            => [ :first ],
      "hvals"            => [ :first ],
      "hgetall"          => [ :first ],
      "incr"             => [ :first ],
      "incrby"           => [ :first ],
      "info"             => [],
      "keys"             => [ :first, :all ],
      "lastsave"         => [],
      "lindex"           => [ :first ],
      "llen"             => [ :first ],
      "lpop"             => [ :first ],
      "lpush"            => [ :first ],
      "lrange"           => [ :first ],
      "lrem"             => [ :first ],
      "lset"             => [ :first ],
      "ltrim"            => [ :first ],
      "mapped_mget"      => [ :all, :all ],
      "mget"             => [ :all ],
      "monitor"          => [ :monitor ],
      "move"             => [ :first ],
      "mset"             => [ :alternate ],
      "msetnx"           => [ :alternate ],
      "quit"             => [],
      "randomkey"        => [],
      "rename"           => [ :all ],
      "renamenx"         => [ :all ],
      "rpop"             => [ :first ],
      "rpoplpush"        => [ :all ],
      "rpush"            => [ :first ],
      "sadd"             => [ :first ],
      "save"             => [],
      "scard"            => [ :first ],
      "sdiff"            => [ :all ],
      "sdiffstore"       => [ :all ],
      "select"           => [],
      "set"              => [ :first ],
      "setnx"            => [ :first ],
      "shutdown"         => [],
      "sinter"           => [ :all ],
      "sinterstore"      => [ :all ],
      "sismember"        => [ :first ],
      "slaveof"          => [],
      "smembers"         => [ :first ],
      "smove"            => [ :exclude_last ],
      "sort"             => [ :sort  ],
      "spop"             => [ :first ],
      "srandmember"      => [ :first ],
      "srem"             => [ :first ],
      "sunion"           => [ :all ],
      "sunionstore"      => [ :all ],
      "ttl"              => [ :first ],
      "type"             => [ :first ],
      "zadd"             => [ :first ],
      "zcard"            => [ :first ],
      "zincrby"          => [ :first ],
      "zrange"           => [ :first ],
      "zrangebyscore"    => [ :first ],
      "zrem"             => [ :first ],
      "zremrangebyscore" => [ :first ],
      "zrevrange"        => [ :first ],
      "zscore"           => [ :first ],
      "[]"               => [ :first ],
      "[]="              => [ :first ]
    }
    ALIASES = {
          "flush_db" => "flushdb",
          "flush_all" => "flushall",
          "last_save" => "lastsave",
          "key?" => "exists",
          "delete" => "del",
          "randkey" => "randomkey",
          "list_length" => "llen",
          "push_tail" => "rpush",
          "push_head" => "lpush",
          "pop_tail" => "rpop",
          "pop_head" => "lpop",
          "list_set" => "lset",
          "list_range" => "lrange",
          "list_trim" => "ltrim",
          "list_index" => "lindex",
          "list_rm" => "lrem",
          "set_add" => "sadd",
          "set_delete" => "srem",
          "set_count" => "scard",
          "set_member?" => "sismember",
          "set_members" => "smembers",
          "set_intersect" => "sinter",
          "set_intersect_store" => "sinterstore",
          "set_inter_store" => "sinterstore",
          "set_union" => "sunion",
          "set_union_store" => "sunionstore",
          "set_diff" => "sdiff",
          "set_diff_store" => "sdiffstore",
          "set_move" => "smove",
          "set_unless_exists" => "setnx",
          "rename_unless_exists" => "renamenx",
          "type?" => "type",
          "zset_add" => "zadd",
          "zset_count" => "zcard",
          "zset_range_by_score" => "zrangebyscore",
          "zset_reverse_range" => "zrevrange",
          "zset_range" => "zrange",
          "zset_delete" => "zrem",
          "zset_score" => "zscore",
          "zset_incr_by" => "zincrby",
          "zset_increment_by" => "zincrby"
        }
    # support previous versions of redis gem
    #ALIASES = (defined? Redis::Client) ? Redis::Client::ALIASES : Redis::ALIASES
    #ALIASES = (defined? Redis::Client) ? Redis.instance_methods : Redis::ALIASES
    attr_accessor :namespace

    def initialize(namespace, options = {})
      @namespace = namespace
      @redis = options[:redis]
    end

    # Ruby defines a now deprecated type method so we need to override it here
    # since it will never hit method_missing
    def type(key)
      method_missing(:type, key)
    end

    def method_missing(command, *args, &block)
      (before, after) = COMMANDS[command.to_s] ||
        COMMANDS[ALIASES[command.to_s]]

      # Add the namespace to any parameters that are keys.
      case before
      when :first
        args[0] = add_namespace(args[0]) if args[0]
      when :all
        args = add_namespace(args)
      when :exclude_first
        first = args.shift
        args = add_namespace(args)
        args.unshift(first) if first
      when :exclude_last
        last = args.pop
        args = add_namespace(args)
        args.push(last) if last
      when :alternate
        args = [ add_namespace(Hash[*args]) ]
      end

      # Dispatch the command to Redis and store the result.
      result = @redis.send(command, *args, &block)

      # Remove the namespace from results that are keys.
      result = rem_namespace(result) if after == :all

      result
    end

  private
    def add_namespace(key)
      return key unless key && @namespace

      case key
      when Array
        key.map {|k| add_namespace k}
      when Hash
        Hash[*key.map {|k, v| [ add_namespace(k), v ]}.flatten]
      else
        "#{@namespace}:#{key}"
      end
    end

    def rem_namespace(key)
      return key unless key && @namespace

      case key
      when Array
        key.map {|k| rem_namespace k}
      when Hash
        Hash[*key.map {|k, v| [ rem_namespace(k), v ]}.flatten]
      else
        key.to_s.gsub /^#{@namespace}:/, ""
      end
    end
  end
end
