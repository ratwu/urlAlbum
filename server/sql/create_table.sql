CREATE TABLE IF NOT EXISTS `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) DEFAULT NULL COMMENT 'Open用户名',
  `uuid` char(36) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `userRole` enum('admin','user','consultant') DEFAULT 'user' COMMENT '用户角色，admin为Site站点管理员',
  `accessToken` varchar(40) DEFAULT NULL,
  `expired` datetime DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDb  DEFAULT CHARSET=utf8 AUTO_INCREMENT=455 ;

CREATE TABLE `website` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;