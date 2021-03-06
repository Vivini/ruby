require_relative '../spec_helper'
require_relative '../fixtures/classes'

describe "BasicSocket#write_nonblock" do
  SocketSpecs.each_ip_protocol do |family, ip_address|
    before :each do
      @r = Socket.new(family, :DGRAM)
      @w = Socket.new(family, :DGRAM)

      @r.bind(Socket.pack_sockaddr_in(0, ip_address))
      @w.connect(@r.getsockname)
    end

    after :each do
      @r.close unless @r.closed?
      @w.close unless @w.closed?
    end

    it "sends data" do
      @w.write_nonblock("aaa").should == 3
      IO.select([@r], nil, nil, 2)
      @r.recv_nonblock(5).should == "aaa"
    end

    platform_is :linux do
      it 'does not set the IO in nonblock mode' do
        require 'io/nonblock'
        @w.should_not.nonblock?
        @w.write_nonblock("aaa").should == 3
        @w.should_not.nonblock?
      end
    end

    platform_is_not :linux, :windows do
      it 'sets the IO in nonblock mode' do
        require 'io/nonblock'
        @w.should_not.nonblock?
        @w.write_nonblock("aaa").should == 3
        @w.should.nonblock?
      end
    end
  end
end
