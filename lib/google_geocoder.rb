module GoogleGeocoder
  def self.get_position(place, cc_tld)

    results = geocode(address: place, region: cc_tld)['results']

    if results.length > 0
      result = results[0]
      location = result['geometry']['location']
      return {'lat' => location['lat'], 'lon' => location['lng']}
    else
      raise "empty geocoding response for place #{place}, region #{region}"
    end
 
  end

  def self.get_cc_tld(country)

    results = geocode(country: country)['results']
    
    if results.length > 0
      result = results[0]
      address_components = result['address_components']
      country_codes = address_components.select{|component| component['types'] == ['country', 'political']}.collect{|component| component['short_name']} 
      if country_codes.length > 0
        return @@cc_tlds[country_codes[0]]
      else
        raise "unable to find country code from geocoding response for country #{country}"
      end
    else
      raise "empty geocoding response for country #{country}"
    end
    
  end
 
  def self.geocode(address: nil, country: nil, region: nil)

    require 'open-uri'
    require 'json'

    uri = URI.parse("http://maps.googleapis.com")
    uri.path = "/maps/api/geocode/json"
    params = {:sensor => false}
    unless address.nil?
      params[:address] = address 
    end
    unless country.nil?
      params[:components] = "country:#{country}"
    end
    unless region.nil?
      params[:region] = region 
    end
    uri.query = params.to_query

    r = Rails.cache.fetch(uri.to_s, :expires_in => 7.days) do
      open(uri).read
    end

    return JSON.parse(r)

  end

  @@cc_tlds = {
    'AD' => 'ad',
    'AE' => 'ae',
    'AF' => 'af',
    'AG' => 'ag',
    'AI' => 'ai',
    'AL' => 'al',
    'AM' => 'am',
    'AO' => 'ao',
    'AQ' => 'aq',
    'AR' => 'ar',
    'AS' => 'as',
    'AT' => 'at',
    'AU' => 'au',
    'AW' => 'aw',
    'AX' => 'ax',
    'AZ' => 'az',
    'BA' => 'ba',
    'BB' => 'bb',
    'BD' => 'bd',
    'BE' => 'be',
    'BF' => 'bf',
    'BG' => 'bg',
    'BH' => 'bh',
    'BI' => 'bi',
    'BJ' => 'bj',
    'BL' => 'bl',
    'BM' => 'bm',
    'BN' => 'bn',
    'BO' => 'bo',
    'BQ' => 'bq',
    'BR' => 'br',
    'BS' => 'bs',
    'BT' => 'bt',
    'BV' => 'bv',
    'BW' => 'bw',
    'BY' => 'by',
    'BZ' => 'bz',
    'CA' => 'ca',
    'CC' => 'cc',
    'CD' => 'cd',
    'CF' => 'cf',
    'CG' => 'cg',
    'CH' => 'ch',
    'CI' => 'ci',
    'CK' => 'ck',
    'CL' => 'cl',
    'CM' => 'cm',
    'CN' => 'cn',
    'CO' => 'co',
    'CR' => 'cr',
    'CU' => 'cu',
    'CV' => 'cv',
    'CW' => 'cw',
    'CX' => 'cx',
    'CY' => 'cy',
    'CZ' => 'cz',
    'DE' => 'de',
    'DJ' => 'dj',
    'DK' => 'dk',
    'DM' => 'dm',
    'DO' => 'do',
    'DZ' => 'dz',
    'EC' => 'ec',
    'EE' => 'ee',
    'EG' => 'eg',
    'EH' => 'eh',
    'ER' => 'er',
    'ES' => 'es',
    'ET' => 'et',
    'FI' => 'fi',
    'FJ' => 'fj',
    'FK' => 'fk',
    'FM' => 'fm',
    'FO' => 'fo',
    'FR' => 'fr',
    'GA' => 'ga',
    'GB' => 'gb',
    'GD' => 'gd',
    'GE' => 'ge',
    'GF' => 'gf',
    'GG' => 'gg',
    'GH' => 'gh',
    'GI' => 'gi',
    'GL' => 'gl',
    'GM' => 'gm',
    'GN' => 'gn',
    'GP' => 'gp',
    'GQ' => 'gq',
    'GR' => 'gr',
    'GS' => 'gs',
    'GT' => 'gt',
    'GU' => 'gu',
    'GW' => 'gw',
    'GY' => 'gy',
    'HK' => 'hk',
    'HM' => 'hm',
    'HN' => 'hn',
    'HR' => 'hr',
    'HT' => 'ht',
    'HU' => 'hu',
    'ID' => 'id',
    'IE' => 'ie',
    'IL' => 'il',
    'IM' => 'im',
    'IN' => 'in',
    'IO' => 'io',
    'IQ' => 'iq',
    'IR' => 'ir',
    'IS' => 'is',
    'IT' => 'it',
    'JE' => 'je',
    'JM' => 'jm',
    'JO' => 'jo',
    'JP' => 'jp',
    'KE' => 'ke',
    'KG' => 'kg',
    'KH' => 'kh',
    'KI' => 'ki',
    'KM' => 'km',
    'KN' => 'kn',
    'KP' => 'kp',
    'KR' => 'kr',
    'KW' => 'kw',
    'KY' => 'ky',
    'KZ' => 'kz',
    'LA' => 'la',
    'LB' => 'lb',
    'LC' => 'lc',
    'LI' => 'li',
    'LK' => 'lk',
    'LR' => 'lr',
    'LS' => 'ls',
    'LT' => 'lt',
    'LU' => 'lu',
    'LV' => 'lv',
    'LY' => 'ly',
    'MA' => 'ma',
    'MC' => 'mc',
    'MD' => 'md',
    'ME' => 'me',
    'MF' => 'mf',
    'MG' => 'mg',
    'MH' => 'mh',
    'MK' => 'mk',
    'ML' => 'ml',
    'MM' => 'mm',
    'MN' => 'mn',
    'MO' => 'mo',
    'MP' => 'mp',
    'MQ' => 'mq',
    'MR' => 'mr',
    'MS' => 'ms',
    'MT' => 'mt',
    'MU' => 'mu',
    'MV' => 'mv',
    'MW' => 'mw',
    'MX' => 'mx',
    'MY' => 'my',
    'MZ' => 'mz',
    'NA' => 'na',
    'NC' => 'nc',
    'NE' => 'ne',
    'NF' => 'nf',
    'NG' => 'ng',
    'NI' => 'ni',
    'NL' => 'nl',
    'NO' => 'no',
    'NP' => 'np',
    'NR' => 'nr',
    'NU' => 'nu',
    'NZ' => 'nz',
    'OM' => 'om',
    'PA' => 'pa',
    'PE' => 'pe',
    'PF' => 'pf',
    'PG' => 'pg',
    'PH' => 'ph',
    'PK' => 'pk',
    'PL' => 'pl',
    'PM' => 'pm',
    'PN' => 'pn',
    'PR' => 'pr',
    'PS' => 'ps',
    'PT' => 'pt',
    'PW' => 'pw',
    'PY' => 'py',
    'QA' => 'qa',
    'RE' => 're',
    'RO' => 'ro',
    'RS' => 'rs',
    'RU' => 'ru',
    'RW' => 'rw',
    'SA' => 'sa',
    'SB' => 'sb',
    'SC' => 'sc',
    'SD' => 'sd',
    'SE' => 'se',
    'SG' => 'sg',
    'SH' => 'sh',
    'SI' => 'si',
    'SJ' => 'sj',
    'SK' => 'sk',
    'SL' => 'sl',
    'SM' => 'sm',
    'SN' => 'sn',
    'SO' => 'so',
    'SR' => 'sr',
    'SS' => 'ss',
    'ST' => 'st',
    'SV' => 'sv',
    'SX' => 'sx',
    'SY' => 'sy',
    'SZ' => 'sz',
    'TC' => 'tc',
    'TD' => 'td',
    'TF' => 'tf',
    'TG' => 'tg',
    'TH' => 'th',
    'TJ' => 'tj',
    'TK' => 'tk',
    'TL' => 'tl',
    'TM' => 'tm',
    'TN' => 'tn',
    'TO' => 'to',
    'TR' => 'tr',
    'TT' => 'tt',
    'TV' => 'tv',
    'TW' => 'tw',
    'TZ' => 'tz',
    'UA' => 'ua',
    'UG' => 'ug',
    'UM' => 'um',
    'US' => 'us',
    'UY' => 'uy',
    'UZ' => 'uz',
    'VA' => 'va',
    'VC' => 'vc',
    'VE' => 've',
    'VG' => 'vg',
    'VI' => 'vi',
    'VN' => 'vn',
    'VU' => 'vu',
    'WF' => 'wf',
    'WS' => 'ws',
    'YE' => 'ye',
    'YT' => 'yt',
    'ZA' => 'za',
    'ZM' => 'zm',
    'ZW' => 'zw',
  }
end