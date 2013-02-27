class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    def initialize(user)
	    user ||= User.new
	    friends = user.inverse_friends.map(&:id) + user.friends.map(&:id) + [user.id]
	    
	    # Posts
	    can :show, Post, :user_id => friends
	    can :destroy, Post, :user_id => user.id
	    can [:like_post, :mentions, :twitter, :facebook, :favs], Post
    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
  end
end
