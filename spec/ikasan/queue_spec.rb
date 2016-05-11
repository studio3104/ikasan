require 'spec_helper'
require 'ikasan/queue'

describe Ikasan::Queue do
  let(:queue) { Ikasan::Queue.new }

  before :each do
    queue.set(room: 'studio3104', message: 'cool')
    queue << { room: 'studio3104', message: 'smart' }
    queue << { room: 'moznion', message: 'crazy' }
  end

  after :each do
    q = Array.new(1)
    while !q.empty? do
      q = queue.retrieve
    end
  end

  it '#empty?' do
    expect(queue.empty?).to be_a FalseClass
    expect(Ikasan::Queue.new.empty?).to be_a TrueClass
  end

  it '#retrieve' do
    expect(queue.retrieve).to eq([
      { room: 'studio3104', message: 'cool' },
      { room: 'moznion', message: 'crazy' },
    ])
    expect(queue.retrieve).to eq([{ room: 'studio3104', message: 'smart' }])
    expect(queue.retrieve).to eq([])
  end

  it '#unshift' do
    queue.unshift(room: 'moznion', message: 'fire!')
    expect(queue.retrieve).to eq([
      { room: 'studio3104', message: 'cool' },
      { room: 'moznion', message: 'fire!' },
    ])
  end

  it '#freeze' do
    queue.freeze({room: 'studio3104', message: 'freeze!'}, 3600)
    expect(queue.retrieve).to eq([{ room: 'moznion', message: 'crazy' }])
    expect(queue.frozen_rooms).to eq(['studio3104'])

    # trying to enqueue to studio3104 room
    queue << {room: 'studio3104', message: 'frozen?'}
    expect(queue.retrieve).to eq([])
  end

  it '#defrost' do
    queue.freeze({room: 'studio3104', message: 'freeze!'})
    expect(queue.frozen_rooms).to eq(['studio3104'])
    sleep 1
    queue.defrost!
    expect(queue.frozen_rooms).to eq([])
  end
end
