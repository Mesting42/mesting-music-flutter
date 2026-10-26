enum LegalDocumentType { userAgreement, privacyPolicy }

class LegalDocumentSection {
  const LegalDocumentSection({required this.title, required this.body});

  final String title;
  final String body;
}

class LegalDocument {
  const LegalDocument({
    required this.type,
    required this.title,
    required this.summary,
    required this.effectiveDate,
    required this.sections,
  });

  final LegalDocumentType type;
  final String title;
  final String summary;
  final String effectiveDate;
  final List<LegalDocumentSection> sections;
}

const userAgreementDocument = LegalDocument(
  type: LegalDocumentType.userAgreement,
  title: '用户协议',
  summary: '说明使用 Mesting Music 时双方的权利、义务与服务边界。',
  effectiveDate: '生效日期：2026 年 8 月 26 日',
  sections: [
    LegalDocumentSection(
      title: '适用范围与接受',
      body:
          '本协议适用于你下载、安装、注册、登录或使用 Mesting Music 及其提供的音乐收藏、个人资料、社交互动和账号同步服务。点击同意或继续使用前，请先完整阅读本协议；不同意任一条款时，请停止使用需要账号或联网支持的功能。',
    ),
    LegalDocumentSection(
      title: '账号与使用规则',
      body:
          '你应使用真实、合法且归你本人控制的手机号或邮箱完成验证，并妥善保管账号和验证码。不得冒用他人身份、干扰服务运行、绕过安全机制、批量抓取内容，或利用本应用从事违法、侵权、骚扰、欺诈等活动。',
    ),
    LegalDocumentSection(
      title: '音乐内容与知识产权',
      body:
          '歌曲、歌词、封面及相关素材的权利归其权利人所有。本应用不是任何第三方音乐平台的官方客户端，不提供破解会员、规避付费或规避版权限制的服务。你仅可在法律和权利人许可的范围内个人使用内容，不得擅自下载后传播、商用或二次发布。',
    ),
    LegalDocumentSection(
      title: '社交内容与互动',
      body:
          '当你使用关注、好友、私信或一起听功能时，应尊重他人隐私与合法权益，不得发布违法、侵权、侮辱、色情、暴力、欺诈或骚扰性内容。你应对自己发布、上传或发送的内容负责；我们可在法律允许的范围内对涉嫌违规内容采取限制展示、删除或限制账号功能等措施。',
    ),
    LegalDocumentSection(
      title: '服务变更与可用性',
      body:
          '网络、设备、地区、第三方接口、版权或会员规则的变化，可能影响搜索、播放、歌词、封面及同步服务的可用性。本应用会尽力维持合理运行，但不承诺所有内容持续可用或完全无中断。涉及重要服务变化时，将在应用内以适当方式说明。',
    ),
    LegalDocumentSection(
      title: '注销与终止',
      body:
          '当你的客户端和服务端已提供“注销账号”功能时，可在设置中提交申请。账号注销后，账号资料及可删除的云端数据将按隐私政策处理，且通常无法恢复；法律法规另有保存期限要求的数据除外。你也可以随时停止使用本应用。',
    ),
    LegalDocumentSection(
      title: '协议更新与联系',
      body:
          '我们可能因功能、服务或法律要求更新本协议。重大变更会在应用内以显著方式提示，并在需要时重新取得你的同意。关于本协议的疑问，请以应用商店开发者主页或应用内公布的联系渠道为准。',
    ),
  ],
);

const privacyPolicyDocument = LegalDocument(
  type: LegalDocumentType.privacyPolicy,
  title: '隐私政策',
  summary: '说明我们处理哪些信息、为何处理，以及你如何管理自己的数据。',
  effectiveDate: '生效日期：2026 年 8 月 26 日',
  sections: [
    LegalDocumentSection(
      title: '我们处理的信息',
      body:
          '为提供账号和云端服务，我们会处理你主动提交或在使用中产生的信息，包括：手机号或邮箱及其验证结果、账号标识、昵称、头像、个人简介和主页背景；收藏、歌单、播放历史等音乐资料；关注、好友关系、私信内容与一起听互动所需的数据。',
    ),
    LegalDocumentSection(
      title: '设备与本地信息',
      body:
          '为保障运行、安全和更新，我们可能处理必要的设备与网络状态信息，例如系统版本、应用版本、网络可用状态及故障日志。你主动选择的头像、背景或本地媒体会先由系统授权读取，并仅用于你选择的展示、上传或播放功能。应用还会在本机保存登录凭证、播放队列、封面缓存和同步缓存，以提高使用体验。',
    ),
    LegalDocumentSection(
      title: '使用目的',
      body:
          '上述信息用于完成注册登录和身份验证、展示个人资料、同步音乐资料、提供社交和私信服务、处理账号注销请求、排查故障与保障账号安全。我们不会将你的个人信息出售给任何第三方，也不会将信息用于与上述目的无关的广告定向。',
    ),
    LegalDocumentSection(
      title: '存储与服务提供方',
      body:
          '正式稳定版的账号、资料、社交及文件同步服务目前使用腾讯云 CloudBase 提供的认证、数据库、云函数和文件存储能力。若你自愿安装“Java + MySQL 测试版”，同类数据会改由该独立测试服务处理；它与稳定版安装包、更新通道和账号数据相互独立。音乐内容或链接来自第三方服务时，还应同时遵守对应服务的规则。',
    ),
    LegalDocumentSection(
      title: '共享、公开与委托',
      body:
          '我们仅在实现功能所必需、获得你的单独同意，或法律法规要求的情况下共享、公开或提供信息。向 CloudBase 等基础服务提供方传输数据仅限其受托提供相关服务所需的范围。你的头像、昵称、个人简介及你主动公开的动态，可能会被你允许访问的其他用户看到。',
    ),
    LegalDocumentSection(
      title: '你的权利',
      body:
          '你可以在个人资料、设置和账号相关页面查询、修改或删除部分资料；可以退出登录、取消关注关系，或在功能可用时申请注销账号。注销会删除账号及可删除的云端资料，同时清理当前设备中的登录状态；因法律法规或争议处理需要保存的信息，将在法定期限内保留。',
    ),
    LegalDocumentSection(
      title: '安全与保留',
      body:
          '我们采取传输加密、访问控制和设备安全存储等合理措施保护信息，并在实现服务目的所需的最短期限内保存。网络传输和互联网环境无法做到绝对安全，请不要通过昵称、简介或私信发送银行卡密码、验证码等敏感信息。',
    ),
    LegalDocumentSection(
      title: '未成年人、更新与联系',
      body:
          '若你是未成年人，请在监护人同意和指导下使用本应用。我们更新本政策时，会在应用内以适当方式提示；涉及重要变化时，将在需要时重新取得同意。关于隐私权利的咨询，请以应用商店开发者主页或应用内公布的联系渠道为准。',
    ),
  ],
);

LegalDocument legalDocumentFor(LegalDocumentType type) {
  return switch (type) {
    LegalDocumentType.userAgreement => userAgreementDocument,
    LegalDocumentType.privacyPolicy => privacyPolicyDocument,
  };
}
