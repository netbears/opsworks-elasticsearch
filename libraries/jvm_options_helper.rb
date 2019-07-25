# frozen_string_literal: true

module JvmOptions
  module Helper
    extend Chef::Mixin::ShellOut

    # get total ram
    def self.total_ram
      command = "cat /proc/meminfo | grep MemTotal | awk '{print int($2/1024)}'"
      shell_out(command).stdout.to_i
    end

    # compute jvm amount
    def self.compute_jvm_amount
      jvm_amount = (total_ram * 0.6 / 1024).to_i
      jvm_amount
    end

    # return jvm initial heap size
    def self.jvm_initial_heap_size
      "-Xms#{compute_jvm_amount}g"
    end

    # return jvm initial heap size
    def self.jvm_maximum_heap_size
      "-Xmx#{compute_jvm_amount}g"
    end
  end
end
