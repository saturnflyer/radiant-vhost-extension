ScopedAccess
============

## Nested with_scope

### maiha : February 22nd, 2006

In this article I'll explain what "nested with_scope" is and why we need it.

## What is 'with_scope'?

It is a public class method of ActiveRecord::Base
that offers a workspace limited by a given scoping parameter.

    Member.count         # => SELECT COUNT(*) FROM members
    Member.find(1)       # => SELECT *        FROM members WHERE id = 1
    Member.delete_all    # => DELETE          FROM members

    Member.with_scope(:find=>{:conditions=>"group_name = 'Berryz'"}, :create=>{:group_name => 'Berryz'}) do
      Member.count       # => SELECT COUNT(*) FROM members WHERE group_name = 'Berryz'
      Member.find(1)     # => SELECT *        FROM members WHERE group_name = 'Berryz' AND id = 1
      Member.delete_all  # => DELETE          FROM members WHERE group_name = 'Berryz'
      Member.create
        # >> #<Member: @attributes=>{:group_name=>"Berryz"}>
    end

This means that the given block is executed within a limited scope
that forces the Article#find method to add the condition: "group_name = 'Berryz'",
and forces Article#create to set the attribute 'group_name' to 'Berryz' automatically.

If this scope could be nested, we'd have following three advantages:

+ convenient reuse
+ exclusive scope
+ around filter

## convenient reuse

If we could split constraints into atomic pieces,
we could apply constraints composed of those pieces by merging (nesting) scopes.

    ValidUser  = {:find=>{:conditions=>"enabled = true"}, :create...}
    ActiveUser = {:find=>{:conditions=>"logined = true"}, :create...}
    AdminGroup = {:find=>{:conditions=>"group_id = 1"},   :create...}
    StaffGroup = {:find=>{:conditions=>"group_id = 2"},   :create...}

    User.with_scope(ValidUser)
      valid_users = User.find(:all)
    end

    User.with_scope(AdminGroup)
      all_admins = User.find(:all)
    end

    User.with_scope(ActiveUser)
      User.with_scope(AdminGroup)
        active_admins = User.find(:all)
      end
    end

Without nesting, we would have to handle all possible combinations separately.

    valid_user_scoping   = {:find=>{:conditions=>"enabled = true"}, :create...}
    active_user_scoping  = {:find=>{:conditions=>"logined = true"}, :create...}
    admin_group_scoping  = {:find=>{:conditions=>"group_id = 1"},   :create...}
    staff_group_scoping  = {:find=>{:conditions=>"group_id = 2"},   :create...}
    active_admin_scoping = ...
    active_staff_scoping = ...
    active_and_valid_user
    ...

This is the first reason why we need nested scope.

## exclusive scope

Sometimes want to ignore any previous scopings (limitations).
For example,
let's imagine we want to notify a user of the total number of messages in a webmail system.
There is no way of knowing total count of mails once we entered into a scoping,
because all accessing methods to Mail are restricted within a specified scoping.
So, we need a 'with_exclusive_scope' method that can be nested and can ignore all previous scopings.

    Mail.with_scope(:find=>{:conditions=>"user_id = ..."}) do
      count = Mail.count     # => SELECT COUNT(*) FROM mails WHERE user_id = ...
      Mail.with_exclusive_scope({}) do
        count = Mail.count   # => SELECT COUNT(*) FROM mails
      end
    end

This is the second reason why we need nested 'with_scope' and 'with_exclusive_scope'.

## around filter

We have some form of access control in almost applications.
It is too painful and boring to check on our controllers whether requests are illegal accesses or not.

Let's imagine web-based mail system like gmail.
A controller for the main user page would be like this.

    class UserMailController < ApplicationController
      def list
        @mails = Mail.find(:all, :conditions=>["user_id = ?", session[:current_user].id])
      end

      def show
        @mail = Mail.find(params[:id])
        unless @mail.user_id == session[:current_user].id
          @mail = nil
        end
      end

      def update
        @mail = Mail.find(params[:id])
        unless @mail.user_id == session[:current_user].id
          @mail.update_attributes(params[:mail])
        end
      end

      def destroy
        @mail = Mail.find(params[:id])
        if @mail.user_id == session[:current_user].id
          @mail.destroy
        end
      end

      def create
        @mail = Mail.new(params[:mail])
        @mail.user_id = session[:current_user].id
        @mail.save
      end

As we can see, there is a lot of repetition.
We want to write logic to manage mails in this controller, not to control access.
So we'll rewrite it by using 'with_scope' like this.

    class MailController < ApplicationController
    protected
      def mine
        {
          :find   => {:conditions => ["user_id = ?", session[:current_user].id]},
          :create => {:user_id => session[:current_user].id},
        }
      end

    public
      def list
        Mail.with_scope(mine) do
          @mails = Mail.find(:all)
        end
      end

      def show
        Mail.with_scope(mine) do
          @mail = Mail.find(params[:id])
        end
      end

      def update
        Mail.with_scope(mine) do
          Mail.update(params[:id], params[:mail])
        end
      end

      def destroy
        Mail.with_scope(mine) do
          Mail.destroy(params[:id])
        end
      end

      def create
        Mail.with_scope(mine) do
          Mail.create(params[:mail])
        end
      end
    end

Then we can remove redundant 'with_scope' code to an around_filter
that limits scoping in #before and releases it in #after.

    class ScopedAccess::Filter
      def initialize (klass, method_scoping)
        ...
      end
      def before (controller)
        @klass.scoped_methods << @method_scoping   # means enable 'with_scope'
      end
      def after (controller)
        @klass.scoped_methods.pop                  # means disable 'with_scope'
      end
    end

Now we can rewrite our controller like this!

    class UserMailController < ApplicationController
      around_filter ScopedAccess::Filter.new(Mail, :mine)

    protected
      def mine
        {
          :find   => {:conditions => ["user_id = ?", session[:current_user].id]},
          :create => {:user_id  => session[:current_user].id},
        }
      end

    public
      def list
        @mails = Mail.find(:all)
      end

      def show
        @mail = Mail.find(params[:id])
      end

      def update
        Mail.update(params[:id], params[:mail])
      end

      def destroy
        Mail.destroy(params[:id])
      end

      def create
        Mail.create(params[:mail])
      end
    end

Don't you like this code?
Although we can now enjoy this code in current trunk,
it easily causes errors when we, or some libraries, use 'with_scope' in the given actions.
This is the final reason why we need nested 'with_scope'.

## Furthermore

When we use the 'with_scope' method for constraints or restrictions,
there is no difference between :create and :find in most cases
because the scoping handles access control to resources.
In these cases, it's painful preparing similar conditions for both uses.

I'm using a plugin named 'scoped_access' to solve this.
It provides three classes: ScopedAccess::Filter, ScopedAccess::MethodScoping, and ScopedAccess::ClassScoping.

## ScopedAccess::Filter

ScopedAccess::Filter is the same around_filter shown in above section.
It takes your model class and method_scoping hash as arguments,
and ensures that all actions in the controller are executed under the given scoping.

## ScopedAccess::MethodScoping

ScopedAccess::MethodScoping is a 'method_scoping' generator.
It is instantiated with attributes (or a hash) that define the constraints.
We can add constraints by using the 'add(statement_string)' or '[]=' methods.
The public method 'method_scoping' returns a hash object.

For example:

    admin_group = MethodScoping.new(:group_id=>1)
    admin_group.method_scoping
    => {
         :find=>{:conditions=>["group_id = ?", 1]},
         :create => {:group_id => 1},
       }

Additionally, 'with_scope' can recognize 'method_scoping' duck typing,
so we can write natural code like the following without explicitly calling the method.

    Member.with_scope(MethodScoping.new(:group_id=>1)) do
      Member.find(:all)
      Member.create(...)
    end

## ScopedAccess::ClassScoping

Let's consider a more complex case such as eager loading
in the following has_many associations.

    Group
      + Member

Here, we assume the 'id' column is defined in all tables.
Eager loading will fail due to an ambiguous column name
because MethodScoping doesn't know the table name.

    Group.with_scope(MethodScoping.new(:id=>1)) do
      Group.find(:all, :include=>"members") # 
        => "SELECT ... WHERE id = 1"  # there are 'id' columns in groups and members

The third class 'ClassScoping' works like the 'MethoScoping' class
except it mentions table name (class name).
It takes an ActiveRecord class for first argument, and affects only the :find option.

    admin_group = ClassScoping.new(Group, :id=>1)
    admin_group.method_scoping
    => {
         :find   => {:conditions=>["( groups.id = ? )", [1]]},
         :create => {"id" => 1}
       }

    Group.with_scope(ClassScoping.new(Group, :id=>1)) do
      Group.find(:all, :include=>"members")
        => "SELECT ... WHERE groups.id = 1"

The 'scoped_access' plugin adds a new method named 'scoped_access' to ActionController::Base,
a macro to "around_filter ScopedAccess::Filter.new(*args))".
It should be noted that the MethodScoping class has a '+' method for the merge operation.

We can simplify our controllers like this!!

    module Scopings
      ActiveMember     = MethodScoping.new(:deleted => false)
      ElementarySchool = MethodScoping.new(:grade => 1)
      JuniorHighSchool = MethodScoping.new(:grade => 2)
    end

    class ActiveMemberController < ApplicationController
      scoped_access Member, Scopings::ActiveMember
    protected
      def mine
        ClassScoping.new(Member, :id=>session[:current_member].id)
      end
    public
      def show
        @member = Member.with_scope(mine){ Member.find(params[:id]) }
      end
    end

    class JuniorHighSchoolMemberController < ActiveMemberController 
      scoped_access Member, Scopings::JuniorHighSchool
      def list
        @members = Member.find(:all)
      end
    end

    class ElementarySchoolMemberController < ActiveMemberController 
      scoped_access Member, Scopings::ElementarySchool
      def list
        Member.with_exclusive_scope(Scopings::JuniorHighSchool + Scopings::ActiveMember) do
          @junior_high_school_members_count = Member.count
        end

        @members = Member.find(:all)
      end
    end

## More ideas to be implemented

Although it's still just an idea,
this nested 'with_scope' would help in constructing join conditions.
In short, we construct a condition not in the 'LEFT JOIN ON' or 'WHERE' sentence,
but in outer scoping restrictions like this.

    Author.find_with_associations({:posts=>:comments})
    =>
      Author.with_scope(join_condition1) do
        Post.with_scope(join_condition2) do
          Author.find(:all, :include=>{:posts=>:comments}, :without_condition=>true)
        end
      end

These above samples are very simple.
I have great confidence that nested scoping helps us much more in complex systems
because nested scopes (constraints) will remove some complexity
and finally give the controller simple CRUD operations like the last example!

Happy RoR with nested 'with_scope'!!

### ticket
 http://dev.rubyonrails.org/ticket/3407

### 'scoped_access' plugin

    % ruby script/plugin install http://wota.jp/svn/rails/plugins/branches/stable/scoped_access/

### thanks

Some wrong sentences are corrected by corp. (2006/02/27)
