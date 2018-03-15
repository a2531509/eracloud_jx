<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>   
<script type="text/javascript">

	//金额里面特殊字符的验证以及金额是否大于0
	function checkBalance(str){
		var regsc = /^([^`=?%#!'\"\,\;:\\<>\u00b7\u00d7\u2014\u2018\u2019\u201c\u201d\u2026\u3001\u3002\u300a\u300b\u300e\u300f\u3010\u3011\uff01\uff08\uff09\uff0c\uff1a\uff1b\uff1f])*$/; //特殊字符串
		var regeng = /^[^a-zA-Z]*$/; //英文字符
		var regchn = /^[^\u4E00-\u9FFF]*$/; //中文汉字
		if(str.match(regsc)==null) return "不能包含特殊字符";
		if(str.match(regeng)==null) return "不能包含英文字符";
		if(str.match(regchn)==null) return "不能包含中文汉字";
		return true;
	} 
	
	function timeStamp2String(time){
		var datetime = new Date();     
		datetime.setTime(time);     
		var year = datetime.getFullYear();     
		var month = datetime.getMonth() + 1 < 10 ? "0" + (datetime.getMonth() + 1) : datetime.getMonth() + 1;     
		var date = datetime.getDate() < 10 ? "0" + datetime.getDate() : datetime.getDate();     
		return year + "-" + month + "-" + date; 
	} 
	$(function() {
		$("#feeRate").val($("#feeRate").val()/100);
		$("#merchantId").combobox({
			 url:"merchantRegister/merchantRegisterAction!findALLMerchant.action",
            valueField: 'merchantId', 
            textField: 'merchantName',
            //注册事件
            onChange: function (newValue, oldValue) {
                if (newValue != null) {
                    var thisKey = encodeURIComponent($('#merchantId').combobox('getText')); //搜索词
                    var urlStr = "merchantRegister/merchantRegisterAction!getBizName.action?objStr=" + thisKey;
                    var v = $("#merchantId").combobox("reload", urlStr);
                }
            },
            
        });
		
		//费率类型
		$("#feeType").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'',codeName:"请选择"},{codeValue:'1',codeName:"笔数费率"},{codeValue:'2',codeName:"金额费率"}],
		    onSelect: function(rp){
		    	if(rp.codeValue == ""){
		    		$('#wfdjefl').css('display','none');
		    		$('#wfdbsfl').css('display','none');
		    	}else if(rp.codeValue == "1"){
		    		$('#wfdbsfl').css('display','inline');
		    		$('#wfdjefl').css('display','none');
		    	}else if(rp.codeValue == "2"){
		    		$('#wfdjefl').css('display','inline');
		    		$('#wfdbsfl').css('display','none');
		    	}
		    }
		});
	 

	
		$("#form").form({
			url :"merchantRate/merchantRateAction!saveMerchantRate.action",
			data: $('#form').serialize(),
			onSubmit : function(param) {
				var section_Nums = "";
				var fee_Rates = "";
				if($("#max").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入最大服务费',
						timeout : 1000 * 3
	    			});
					return false;
				}
				
				if($("#max").val()!=''){
					var reg = new RegExp("^[1-9]\\d*|[1-9]\\d*\\.\\d{1,2}|0|0\\.\\d{1,2}$");
					if(!(reg.test($("#max").val()))){
						parent.$.messager.show({
							title :'系统消息',
							msg : '请输入最多两位小数的正浮点数或0',
							timeout : 1000 * 3
		    			});
						return false;
					}
				}
				
				
				if($("#min").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入最小服务费',
						timeout : 1000 * 3
	    			});
					return false;
				}
				if($("#min").val()!=''){
					var reg = new RegExp("^[1-9]\\d*|[1-9]\\d*\\.\\d{1,2}|0|0\\.\\d{1,2}$");
					if(!reg.test($("#min").val())){
						parent.$.messager.show({
							title :'系统消息',
							msg : '请输入最多两位小数的正浮点数或0',
							timeout : 1000 * 3
		    			});
						return false;
					}
				}
				if(Number($("#min").val())-Number($("#max").val())>0){
						parent.$.messager.show({
							title :'系统消息',
							msg : '你输入的最小服务费不能大于最大服务费',
							timeout : 1000 * 3
		    			});
						return false;
				}
				
				if($("#merchantId01").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入商户信息！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				
				if($("#tr_Code").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入交易代码！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				if($("#in_Out").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入收付标志！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				
				if($("#begindate").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入生效日期！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				
				if($("#feeType").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入费率类型！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				if($("#haveSection").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入是否分段标志！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				if($("#haveSection").combobox('getValue')!=''){
					if($("#haveSection").combobox('getValue')=='1'){
						if($("#feeRate").val()==''){
							parent.$.messager.show({
								title :'系统消息',
								msg : '请输入费率！',
								timeout : 1000 * 3
			    			});
							return false;
						}
					}
				}
				var len_init =$("#initshow tr").length;
				if(len_init==0){
					if($("#feeType").combobox('getValue')=='1'&&$("#haveSection").combobox('getValue')=='0'){
		    			var _len = $("#tab1 tr").length;
			    		var reg = new RegExp("^[1-9]\\d*|[1-9]\\d*\\.\\d{1,2}|0|0\\.\\d{1,2}$");
			    		var reg2 = new RegExp("^[1-9]\\d*|0$");
			    		for(var i=0,j=_len;i<j;i++){
			    			if($("#haveSection").combobox('getValue')=="0"){
								if($("#bsflsectionNum"+i).val()==""){
									parent.$.messager.show({
										title :'系统消息',
										msg : '请输入分段额度信息！',
										timeout : 1000 * 3
					    			});
									return false;
			    				}else {
			    					if(!reg2.test($("#bsflsectionNum"+i).val())){
										$("#bsflsectionNum"+i).css("background-color","#F6E5E5");
										$("#bsflsectionNum"+i).focus();
										parent.$.messager.show({
											title :'系统消息',
											msg : '提示：请输入正整数！',
											timeout : 1000 * 3
						    			});
										return false;
									}
									if(checkBalance($("#bsflsectionNum"+i).val())!=true){
										parent.$.messager.show({
											title :'系统消息',
											msg : "提示："+"分段额度"+checkBalance($("#bsflsectionNum"+i).val()),
											timeout : 1000 * 3
						    			});
										return false;
									}
								}
								
								if(i!=_len && Number($("#bsflsectionNum"+i).val())-Number($("#bsflsectionNum"+(i-1)).val())<=0){
									parent.$.messager.show({
										title :'系统消息',
										msg : '分段额度信息错误，必须大于上一段！',
										timeout : 1000 * 3
					    			});
									return false;
								}
							}
			    			
			    			if($("#bsflfeeRatese"+i).val()==""){
			    				parent.$.messager.show({
									title :'系统消息',
									msg : '请输入分段费率！',
									timeout : 1000 * 3
				    			});
								return false;
			    			}else {
				    			if($("#feeType").combobox('getValue')=="1"){/* <#-- 分段笔数 --> */
										if(!reg2.test($("#bsflfeeRatese"+i).val())){
											$("#bsflfeeRatese"+i).focus();
											$("#bsflfeeRatese"+i).css("background-color","#FFECEC");
											parent.$.messager.show({
												title :'系统消息',
												msg : '费率提示：分段笔数只能输入非负整数！',
												timeout : 1000 * 3
							    			});
											return false;
										} 
								}
							}
			    			
			    			if(i!=_len-1){
			    				section_Nums = section_Nums  + $("#bsflsectionNum"+i).val()+ ",";
			    				fee_Rates = fee_Rates  + $("#bsflfeeRatese"+i).val()+ ",";
			    			}else{
			    				section_Nums = section_Nums  + $("#bsflsectionNum"+i).val();
			    				fee_Rates = fee_Rates  + $("#bsflfeeRatese"+i).val();
			    			}
						}
		    		}
		    		
		    	
		    		
		    		
		    		if($("#feeType").combobox('getValue')=='2'&&$("#haveSection").combobox('getValue')=='0'){
		    			var _len = $("#tab2 tr").length;
			    		var reg = new RegExp("^[1-9]\\d*|[1-9]\\d*\\.\\d{1,2}|0|0\\.\\d{1,2}$");
			    		var reg2 = new RegExp("^[1-9]\\d*|0$");
			    		for(var i=0,j=_len;i<j;i++){
			    			if($("#haveSection").combobox('getValue')=="0"){
								if($("#jeflsectionNum"+i).val()==""){
									parent.$.messager.show({
										title :'系统消息',
										msg : '请输入分段额度信息！',
										timeout : 1000 * 3
					    			});
									return false;
			    				}else {
			    					if(!reg2.test($("#jeflsectionNum"+i).val())){
										$("#jeflsectionNum"+i).css("background-color","#F6E5E5");
										$("#jeflsectionNum"+i).focus();
										parent.$.messager.show({
											title :'系统消息',
											msg : '提示：请输入正整数！',
											timeout : 1000 * 3
						    			});
										return false;
									}
									if(checkBalance($("#jeflsectionNum"+i).val())!=true){
										parent.$.messager.show({
											title :'系统消息',
											msg : "提示："+"分段额度"+checkBalance($("#jeflsectionNum"+i).val()),
											timeout : 1000 * 3
						    			});
										return false;
									}
								}
								
								if(i!=_len && Number($("#jeflsectionNum"+i).val())-Number($("#jeflsectionNum"+(i-1)).val())<=0){
									parent.$.messager.show({
										title :'系统消息',
										msg : '分段额度信息错误，必须大于上一段！',
										timeout : 1000 * 3
					    			});
									return false;
								}
							}
			    			
			    			if($("#jeflfeeRatese"+i).val()==""){
			    				parent.$.messager.show({
									title :'系统消息',
									msg : '请输入分段费率！',
									timeout : 1000 * 3
				    			});
								return false;
			    			}else {
				    				if($("#feeType").combobox('getValue')=="2"){/* <#-- 分段金额 --> */
										if(!reg.test($("#jeflfeeRatese"+i).val())){
											$("#jeflfeeRatese"+i).focus();
											$("#jeflfeeRatese"+i).css("background-color","#FFECEC");
											parent.$.messager.show({
												title :'系统消息',
												msg : '费率提示：只能输入最多两位小数的数字！',
												timeout : 1000 * 3
							    			});
											
											return false;
										} 
										if(checkBalance($("#jeflfeeRatese"+i).val())!=true){
											var str="费率"+checkBalance($("#jeflfeeRatese"+i).val());
											parent.$.messager.show({
												title :'系统消息',
												msg : str,
												timeout : 1000 * 3
							    			});
											return false;
										} 
										if(Number($("#jeflfeeRatese"+i).val())>100){
											parent.$.messager.show({
												title :'系统消息',
												msg : '金额费率不能大于100%，请重新填写',
												timeout : 1000 * 3
							    			});
											return false;
										} 
									}
							}
							if(i!=_len-1){
			    				section_Nums = section_Nums  + $("#jeflsectionNum"+i).val()+ ",";
			    				fee_Rates = fee_Rates  + $("#jeflfeeRatese"+i).val()+ ",";
			    			}else{
			    				section_Nums = section_Nums  + $("#jeflsectionNum"+i).val();
			    				fee_Rates = fee_Rates  + $("#jeflfeeRatese"+i).val();
			    			}
						}
		    		}
				}else if(len_init>0){
					for(var i=0;i<len_init;i++){
						if($("#sectionNum"+i).val()!=''&&$("#feeRatese"+i).val()!=''){
							if(i!=len_init-1){
			    				section_Nums = section_Nums  + $("#sectionNum"+i).val()+ ",";
			    				fee_Rates = fee_Rates  + $("#feeRatese"+i).val()+ ",";
			    			}else{
			    				section_Nums = section_Nums  + $("#sectionNum"+i).val();
			    				fee_Rates = fee_Rates  + $("#feeRatese"+i).val();
			    			}
						}
					}
				}else{
					parent.$.messager.show({
						title :'系统消息',
						msg : '参数不正确，无法提交！',
						timeout : 1000 * 3
	    			});
					return false;
				}
	    		
	    		
				param.section_Nums =section_Nums;
				param.fee_Rates = fee_Rates;
				param.dealType='2';
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				
				
			},
			success:function(result) {
				$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status == "0") {
					$dg.datagrid("reload");
					$.modalDialog.openner.datagrid('reload');
					$.modalDialog.handler.dialog('close');
				}else{
					$.messager.show({
						title :  result.title,
						msg : result.msg,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
	function addbsfl(){
        var _len = $("#tab1 tr").length;
        $("#tab1").append("<tr id="+_len+">"+
	 			"<th class='tableleft'>分段笔数"+
	 			"</th>"+
	 			"<td class='tableright'><input type='text' name='bsflsectionNum"+_len+"' id='bsflsectionNum"+_len+"' onkeyup='validRmb(this)' onkeydown='validRmb(this)'  class='textinput'/>笔</td>"+
	 			"<th class='tableleft'>大于分段的费率"+
	 			"</th>"+
	 			"<td class='tableright'><input type='text' name='bsflfeeRatese"+_len+"' id='bsflfeeRatese"+_len+"' onkeyup='validRmb(this)' onkeydown='validRmb(this)' class='textinput'/>分/笔 "+
	 			"</td>"+
	 			"<td class='tableright'>"+
	 				"<a href=\'javascript:void(0);\' onclick=\'deltr("+_len+")\'>删除</a>"+
	 			"</td>"+
	 			"</tr>");            
    }  
	
	
	function deltr(index) {
        $("tr[id='"+index+"']").remove();//删除当前行
    }
	
	
	function addjefl(){
        var _len = $("#tab2 tr").length;
        $("#tab2").append("<tr id="+_len+">"+
	 			"<th class='tableleft'>分段笔数"+
	 			"</th>"+
	 			"<td class='tableright'><input type='text' name='jeflsectionNum"+_len+"' id='jeflsectionNum"+_len+"'  onkeyup='validRmb(this)' onkeydown='validRmb(this)' class='textinput'/>分</td>"+
	 			"<th class='tableleft'>大于分段的费率"+
	 			"</th>"+
	 			"<td class='tableright'><input type='text' name='jeflfeeRatese"+_len+"' id='jeflfeeRatese"+_len+"'  onkeyup='validRmb(this)' onkeydown='validRmb(this)' class='textinput'/>%"+
	 			"</td>"+
	 			"<td class='tableright'>"+
	 				"<a href=\'javascript:void(0);\' onclick=\'deltr("+_len+")\'>删除</a>"+
	 			"</td>"+
	 			"</tr>");            
    }  
	
	function autoCom(){
        if($("#merchantId01").val() == ""){
            $("#merchantName01").val("");
        }
        $("#merchantId01").autocomplete({
            position: {my:"left top",at:"left bottom",of:"#merchantId01"},
            source: function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId01").val(),"queryType":"1"},function(data){
                    response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                },'json');
            },
            select: function(event,ui){
                  $('#merchantId01').val(ui.item.label);
                $('#merchantName01').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
    function autoComByName(){
        if($("#merchantName01").val() == ""){
            $("#merchantId01").val("");
        }
        $("#merchantName01").autocomplete({
            source:function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName01").val(),"queryType":"0"},function(data){
                    response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                },'json');
            },
            select: function(event,ui){
                $('#merchantId01').val(ui.item.value);
                $('#merchantName01').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }

    function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
	
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: scroll;padding: 10px;">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户费率信息</legend>
				<input name="payFeeRate.feeRateId" id="feeRateId" value="${payFeeRate.feeRateId}"   type="hidden"/>
				<input name="payFeeRate.userId" id="userId" value="${payFeeRate.userId}"  type="hidden"/>
				<input name="payFeeRate.chkState" id="chkState" value="${payFeeRate.chkState}"  type="hidden"/>
				<input name="payFeeRate.chkDate" id="chkDate"  value="${payFeeRate.chkDate}"  type="hidden"/>
				<input name="payFeeRate.chkUserId" id="chkUserId" value="${payFeeRate.chkUserId}"  type="hidden"/>
				 <table class="tablegrid" style="width:100%">
					 <tr>
						<th class="tableleft">商户编号
						</th>
						<td class="tableright">
							<input name="payFeeRate.merchantId" id="merchantId01" readonly="readonly" value="${payFeeRate.merchantId}" onkeydown="autoCom()" onkeyup="autoCom()" class="textinput" type="text"/>
						</td>
						<th class="tableleft">商户名称
						</th>
						<td class="tableright">
							<input type="text" name="merchantName" id="merchantName01"  readonly="readonly" value="${merchantName}" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">交易名称</th>
						<td class="tableright">
							<input name="tr_Code"  id="tr_Code" value="${tr_Code}" class="easyui-combobox"   readonly="readonly" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								editable:false,
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '40201010',
									value: '终端_联机消费'
								},{
									label: '40101010',
									value: '终端_脱机消费'
								},{
									label: '40201051',
									value: '终端_联机消费退货'
								}]" />
						</td>
						<th class="tableleft">费率状态</th>
						<td class="tableright">
							<input name="payFeeRate.feeState"  id="feeState" value="${payFeeRate.feeState}" class="easyui-combobox"   style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								editable:false,
								data: [{
									label: '0',
									value: '在用'
								},{
									label: '1',
									value: '停用'
								}]" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">最大服务费</th>
						<td class="tableright">
							<input name="max" id="max" value="${max}"  class="textinput"  type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>(分)
						</td>
						<th class="tableleft">最小服务费</th>
						<td class="tableright">
							<input name="min" id="min" value="${min}"  class="textinput"  type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>(分)
						</td>
					</tr>
					<tr>
						<th class="tableleft">费率类型</th>
						<td class="tableright">
							<input name="payFeeRate.feeType"  id="feeType" value="${payFeeRate.feeType}" class="easyui-combobox"/>
						</td>
						<th class="tableleft">费率</th>
						<td class="tableright">
							<input type="text" name="payFeeRate.feeRate" id="feeRate" value="${payFeeRate.feeRate}" class="textinput" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>
							<span id="wfdjefl" <s:if test='%{payFeeRate.feeType== "1"}'>style="display:none;"</s:if> >%</span>
							<span id="wfdbsfl" <s:if test='%{payFeeRate.feeType== "2"}'>style="display:none;"</s:if> >（分/笔）</span>
						</td>
					</tr>
					<tr>
						<th class="tableleft">收支标志</th>
						<td class="tableright">
							<input name="in_Out"  id="in_Out" value="${in_Out}" class="easyui-combobox"  style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								editable:false,
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '0',
									value: '收'
								},{
									label: '1',
									value: '付'
								}]" />
						</td>
						<th class="tableleft">生效日期</th>
						<td class="tableright">
							<input type="text" name="payFeeRate.begindate" id="begindate"  value="${payFeeRate.begindate}"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,minDate:'%y-%M-%d'})" style="width: 174px;"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">是否采用分段费率</th>
						<td class="tableright">
							<input name="payFeeRate.haveSection"  id="haveSection" value="${payFeeRate.haveSection}"  class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								editable:false,
								onSelect:function(){
									$('#initshow').remove();
									if($('#feeType').combobox('getValue')==''){
										 $('#haveSection').combobox('setValue','');
										 $.messager.alert('系统消息','请先选择费率类型','error');
										 return false;
									}
									if($('#haveSection').combobox('getValue')=='1'||$('#haveSection').combobox('getValue')==''){
										$('#jefee')[0].style.display='none';
										$('#bsfee')[0].style.display='none';
									}
									if( $('#haveSection').combobox('getValue')=='0'&&$('#feeType').combobox('getValue')=='1'){
										$('#bsfee')[0].style.display='block';
										$('#jefee')[0].style.display='none';
									}
									if( $('#haveSection').combobox('getValue')=='0'&&$('#feeType').combobox('getValue')=='2'){
										$('#jefee')[0].style.display='block';
										$('#bsfee')[0].style.display='none';
									}
									},
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '0',
									value: '是'
								},{
									label: '1',
									value: '否'
								}]" />
						</td>
						<th class="tableleft">备注</th>
						<td class="tableright">
							<input name="payFeeRate.note" id="note" value="${payFeeRate.note}"  class="textinput" type="text" />
						</td>
					</tr>
				 </table>
			</fieldset>
					<div id="bsfee" style="display: none;">
					<fieldset>
						<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>分段费率信息</legend>
						 <table id="tab1" class="tablegrid" style="width:100%">
					 		<tr>
				 			<th class="tableleft">分段笔数
				 			</th>
				 			<td class="tableright"><input type="text" name="bsflsectionNum0" id="bsflsectionNum0"  class="textinput " onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>笔</td>
				 			<th class="tableleft">大于分段的费率
				 			</th>
				 			<td class="tableright"><input type="text" name="bsflfeeRatese0" id="bsflfeeRatese0"  class="textinput " onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>分/笔 
				 			</td>
				 			<td class="tableright">
				 				<a id="btn1" href="javascript:void(0);" class="easyui-linkbutton" plain="false" data-options="iconCls:'icon-add'" onclick="addbsfl();"></a>
				 			</td>
				 			</tr>
						 </table>
					</fieldset>
					</div>
					<div id="jefee" style="display: none;">
					<fieldset>
						<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>分段费率信息</legend>
						 <table id="tab2" class="tablegrid" style="width:100%">
				 			<tr>
				 			<th class="tableleft">分段金额
				 			</th>
				 			<td class="tableright"><input type="text" name="jeflsectionNum0" id="jeflsectionNum0"   class="textinput  onkeyup="validRmb(this)" onkeydown="validRmb(this)""/>分</td>
				 			<th class="tableleft">大于分段的费率
				 			</th>
				 			<td class="tableright"><input type="text" name="jeflfeeRatese0" id="jeflfeeRatese0" class="textinput " onkeyup="validRmb(this)" onkeydown="validRmb(this)"/>%
				 			</td>
				 			<td class="tableright">
				 				<a id="btn2" href="javascript:void(0);" class="easyui-linkbutton" plain="false" data-options="iconCls:'icon-add'" onclick="addjefl();"></a>
				 			</td>
				 			</tr>
						 </table>
					</fieldset>
					</div>
			</form>
			<div id="initshow">
							<s:if test='%{payFeeRate.haveSection== "0"}'>
							<div>
							<fieldset>
								<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>分段费率信息</legend>
								 <table class="tablegrid" style="width:100%">
								 	<s:if test='%{payFeeRate.feeType== "1"}'>
									 	<s:iterator value="list" id="item"  status='st'>
									 			<tr>
									 			<th class="tableleft">分段笔数
									 			</th>
									 			<td class="tableright"><input type="text" name="rateSection.id.sectionNum"  onkeyup="validRmb(this)" onkeydown="validRmb(this)" id="sectionNum<s:property value='#st.index'/>" value="${id.sectionNum}" class="textinput easyui-validatebox"/>笔</td>
									 			<th class="tableleft">大于分段的费率
									 			</th>
									 			<td class="tableright"><input type="text" name="rateSection.feeRate"  onkeyup="validRmb(this)" onkeydown="validRmb(this)" id="feeRatese<s:property value='#st.index'/>"  value="${feeRate/100}" class="textinput easyui-validatebox"/>分/笔</td>
									 			</tr>
									 	</s:iterator>
								 	</s:if>
								 	<s:else>
									 	<s:iterator value="list" id="item">
									 			<tr>
									 			<th class="tableleft">分段金额
									 			</th>
									 			<td class="tableright"><input type="text" name="rateSection.id.sectionNum" onkeyup="validRmb(this)" onkeydown="validRmb(this)" id="sectionNum<s:property value='#st.index'/>" value="${id.sectionNum}" class="textinput easyui-validatebox"/>分</td>
									 			<th class="tableleft">大于分段的费率
									 			</th>
									 			<td class="tableright"><input type="text" name="rateSection.feeRate"  onkeyup="validRmb(this)" onkeydown="validRmb(this)" id="feeRatese<s:property value='#st.index'/>" value="${feeRate/100}" class="textinput easyui-validatebox"/>%</td>
									 			</tr>
									 	</s:iterator>
								 	</s:else>
								 </table>
							</fieldset>
							</div>
						</s:if>
					</div>
	</div>
</div>